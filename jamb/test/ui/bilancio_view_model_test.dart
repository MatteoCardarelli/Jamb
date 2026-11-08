import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/services/file_archiviati.dart';
import 'package:jamb/domain/entities/bilancio.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/contabilita/bilancio_export.dart';
import 'package:jamb/ui/contabilita/view_model/bilancio_view_model.dart';
import 'package:jamb/ui/core/formato.dart';
import '../../testing/fakes/fake_documento_repository.dart';
import '../../testing/fakes/fake_transazione_repository.dart';
import '../../testing/models/transazione_di_test.dart';

void main() {
  final oggi = DateTime(2026, 11, 8);
  final transazioni = [
    transazioneDiTest('Quote 2025', 100, false, Categoria.quote, data: DateTime(2025, 10, 1)),
    transazioneDiTest('Tende', 30.5, true, Categoria.materiale, data: DateTime(2026, 10, 1)),
  ];

  BilancioViewModel crea(FakeTransazioneRepository t, FakeDocumentoRepository d) =>
      BilancioViewModel(t, d, oggi: oggi);

  group('BilancioViewModel', () {
    test('parte dall\'anno in corso, con il saldo dell\'anno prima', () async {
      final vm = crea(FakeTransazioneRepository(transazioni), FakeDocumentoRepository());
      await pumpEventQueue();
      expect(vm.annoScout, '2026-2027');
      expect(vm.bilancio.saldoIniziale, 10000);
      expect(vm.bilancio.saldoFinale, 6950);
    });

    test('cambiando anno cambia il bilancio', () async {
      final vm = crea(FakeTransazioneRepository(transazioni), FakeDocumentoRepository());
      await pumpEventQueue();
      vm.scegliAnno('2025-2026');
      expect(vm.bilancio.saldoIniziale, 0);
      expect(vm.bilancio.totaleEntrate, 10000);
    });

    // Mai un saldo a zero al posto di un errore.
    test('un errore di lettura diventa uno stato di errore', () async {
      final vm = crea(
        FakeTransazioneRepository(const [],
            erroreLettura: const JambException(TipoErrore.rete, 'Nessuna connessione')),
        FakeDocumentoRepository(),
      );
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
      expect(vm.errore, 'Nessuna connessione');
    });

    test('archivia il PDF nella radice del Drive di Branca, col nome dell\'anno scelto', () async {
      final documenti = FakeDocumentoRepository();
      final vm = crea(FakeTransazioneRepository(transazioni), documenti);
      await pumpEventQueue();
      vm.scegliAnno('2025-2026');

      await vm.archiviaPdf(unita: 'Reparto Velino');

      final file = documenti.caricati.single;
      expect(file.nome, 'Bilancio 2025-2026 - 08-11-2026.pdf');
      expect(ascii.decode(file.byte.sublist(0, 5)), '%PDF-');
      expect(documenti.archivi[ArchivioDocumenti.driveBranca]!.single.parentId, isNull);
    });

    // La schermata lo apre subito dopo averlo archiviato.
    test('il documento archiviato si può aprire', () async {
      final documenti = FakeDocumentoRepository();
      final vm = crea(FakeTransazioneRepository(transazioni), documenti);
      await pumpEventQueue();

      final documento = await vm.archiviaCsv(unita: 'Reparto');

      expect(documento.apribile, isTrue);
      expect(await vm.urlFile(documento), contains(documento.nome));
    });

    test('il PDF si genera anche per un anno senza movimenti', () async {
      final documenti = FakeDocumentoRepository();
      final vm = crea(FakeTransazioneRepository(const []), documenti);
      await pumpEventQueue();
      await vm.archiviaPdf(unita: 'Reparto');
      expect(documenti.caricati.single.byte, isNotEmpty);
    });

    test('il CSV ha un nome ammesso dall\'archivio', () async {
      final documenti = FakeDocumentoRepository();
      final vm = crea(FakeTransazioneRepository(transazioni), documenti);
      await pumpEventQueue();
      await vm.archiviaCsv(unita: 'Reparto');
      final nome = documenti.caricati.single.nome;
      expect(erroreNomeDocumento(nome), isNull);
      expect(mimeDocumenti[estensioneDi(nome)], 'text/csv');
    });

    test('un errore di archiviazione arriva alla View', () async {
      final documenti = FakeDocumentoRepository()
        ..erroreScrittura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = crea(FakeTransazioneRepository(transazioni), documenti);
      await pumpEventQueue();
      await expectLater(vm.archiviaCsv(unita: 'Reparto'), throwsA(isA<JambException>()));
    });
  });

  group('esportazione CSV', () {
    final bilancio = Bilancio.daTransazioni(transazioni, '2026-2027');

    test('è in UTF-8 con BOM, altrimenti Excel rovina le accentate', () {
      final byte = generaBilancioCsv(unita: 'Unità', bilancio: bilancio);
      expect(byte.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    });

    test('contiene saldo finale e movimenti con la virgola decimale', () {
      final testo = utf8.decode(generaBilancioCsv(unita: 'Unità', bilancio: bilancio));
      expect(testo, contains('Saldo finale;;;69,50'));
      expect(testo, contains('01/10/2026;Tende;Materiale;;30,50'));
    });

    test('un separatore nel testo non sposta le colonne', () {
      expect(campoCsv('Tende; picchetti'), '"Tende; picchetti"');
      expect(campoCsv('La "grande" uscita'), '"La ""grande"" uscita"');
    });

    test('un titolo che sembra una formula non viene eseguito', () {
      expect(campoCsv('=SOMMA(A1)'), "'=SOMMA(A1)");
      expect(campoCsv('@cmd'), "'@cmd");
    });

    test('un saldo negativo resta un numero', () {
      expect(campoCsv('-1.234,50'), '-1.234,50');
    });
  });

  group('importoLeggibile', () {
    test('migliaia col punto e decimali con la virgola', () {
      expect(importoLeggibile(123450), '1.234,50');
      expect(importoLeggibile(5), '0,05');
      expect(importoLeggibile(-1050), '-10,50');
    });
  });
}
