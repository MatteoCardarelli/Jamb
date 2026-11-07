import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/ui/documenti/view_model/documenti_view_model.dart';
import '../../testing/fakes/fake_documento_repository.dart';

Future<void> _attendi() => Future.delayed(Duration.zero);

Documento _file(String id, int giorno, {int? dimensioni}) => Documento(
      id: id,
      nome: id,
      tipo: TipoDocumento.pdf,
      ultimaModifica: DateTime(2025, 11, giorno),
      dimensioni: dimensioni,
      percorsoFile: 'g/u/$id',
    );

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  group('DocumentiViewModel', () {
    test('i recenti sono i file del Drive di Branca dal più recente, senza cartelle', () async {
      final repo = FakeDocumentoRepository(archivi: {
        ArchivioDocumenti.driveBranca: [
          _file('vecchio.pdf', 1),
          _file('nuovo.pdf', 20),
          Documento(id: 'Uscite', nome: 'Uscite', tipo: TipoDocumento.cartella, ultimaModifica: DateTime(2025, 11, 30)),
        ],
        ArchivioDocumenti.modulistica: [_file('modulo.pdf', 25)],
      });
      final vm = DocumentiViewModel(repo);
      await _attendi();

      expect(vm.recenti.map((d) => d.id), ['nuovo.pdf', 'vecchio.pdf']);
    });

    test('un file appena caricato compare tra i recenti', () async {
      final repo = FakeDocumentoRepository();
      final vm = DocumentiViewModel(repo);
      await _attendi();
      expect(vm.recenti, isEmpty);

      await repo.caricaFile(
        ArchivioDocumenti.driveBranca,
        FileDaCaricare(nome: 'verbale.pdf', byte: Uint8List(4)),
        null,
      );
      await _attendi();

      expect(vm.recenti.map((d) => d.nome), ['verbale.pdf']);
    });

    test('la riga del recente riporta data e dimensione', () {
      final vm = DocumentiViewModel(FakeDocumentoRepository());
      expect(vm.infoRecente(_file('a.pdf', 7, dimensioni: 2048)), 'Modificato 7 nov 2025 • 2 KB');
      expect(vm.infoRecente(_file('b.pdf', 7)), 'Modificato 7 nov 2025');
    });
  });
}
