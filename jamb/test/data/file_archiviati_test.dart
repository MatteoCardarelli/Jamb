import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/services/file_archiviati.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import '../../testing/fakes/fake_storage_service.dart';

/// Tipi MIME ammessi da un bucket, letti dalla migrazione che lo crea.
Set<String> _mimeDelBucket(String bucket) {
  final testo = File('../supabase/migrations/20261107143707_archiviazione_documenti.sql')
      .readAsStringSync();
  final riga = RegExp("\\('$bucket', '$bucket', false, \\d+, ARRAY\\[([^\\]]*)\\]")
      .firstMatch(testo)!;
  return RegExp(r"'([^']+)'").allMatches(riga.group(1)!).map((m) => m.group(1)!).toSet();
}

const _rete = JambException(TipoErrore.rete, 'Connessione assente.');

void main() {
  group('estensioneDi', () {
    test('restituisce l\'estensione in minuscolo', () {
      expect(estensioneDi('Verbale Consiglio.PDF'), 'pdf');
      expect(estensioneDi('archivio.tar.zip'), 'zip');
    });

    test('senza estensione restituisce stringa vuota', () {
      expect(estensioneDi('LEGGIMI'), '');
      expect(estensioneDi('.nascosto'), '');
      expect(estensioneDi('punto.'), '');
    });
  });

  test('il percorso usa id ed estensione, non il nome originale', () {
    expect(
      percorsoFile(gruppo: 'g', cartella: 'u', id: 'abc', estensione: 'pdf'),
      'g/u/abc.pdf',
    );
  });

  group('verificaFile', () {
    test('restituisce il tipo MIME di un file ammesso', () {
      expect(
        verificaFile('foto.JPG', 1000, ammessi: mimeRicevute, limite: limiteRicevute),
        'image/jpeg',
      );
    });

    test('rifiuta un tipo non ammesso', () {
      expect(
        () => verificaFile('programma.exe', 10, ammessi: mimeDocumenti, limite: limiteDocumenti),
        throwsA(isA<JambException>()),
      );
    });

    test('rifiuta un file oltre il limite', () {
      expect(
        () => verificaFile('foto.png', limiteRicevute + 1, ammessi: mimeRicevute, limite: limiteRicevute),
        throwsA(isA<JambException>()
            .having((e) => e.messaggio, 'messaggio', 'Il file supera i 10 MB.')),
      );
    });
  });

  // Un tipo ammesso dall'app ma non dal bucket fallirebbe solo al momento
  // del caricamento, sul telefono.
  group('tipi MIME allineati ai bucket', () {
    test('documenti', () {
      expect(_mimeDelBucket(bucketDocumenti), containsAll(mimeDocumenti.values.toSet()));
    });

    test('ricevute', () {
      expect(_mimeDelBucket(bucketRicevute), containsAll(mimeRicevute.values.toSet()));
    });
  });

  group('caricaConCompensazione', () {
    late FakeStorageService archivio;
    final byte = Uint8List.fromList([1, 2, 3]);

    setUp(() => archivio = FakeStorageService());

    Future<String> carica({required Future<String> Function() scriviRiga}) =>
        caricaConCompensazione(
          caricaFile: () => archivio.carica('documenti', 'g/u/x.pdf', byte, 'application/pdf'),
          scriviRiga: scriviRiga,
          eliminaFile: () => archivio.elimina('documenti', ['g/u/x.pdf']),
        );

    test('se la riga si salva il file resta', () async {
      expect(await carica(scriviRiga: () async => 'ok'), 'ok');
      expect(archivio.file.keys, ['documenti/g/u/x.pdf']);
    });

    test('se la riga non si salva il file viene eliminato e l\'errore arriva', () async {
      await expectLater(carica(scriviRiga: () => throw _rete), throwsA(_rete));
      expect(archivio.file, isEmpty);
    });

    test('se fallisce il caricamento la riga non si scrive', () async {
      archivio.erroreCaricamento = _rete;
      var scritta = false;
      await expectLater(
        carica(scriviRiga: () async {
          scritta = true;
          return 'ok';
        }),
        throwsA(_rete),
      );
      expect(scritta, isFalse);
    });

    // Conta l'errore che l'utente può capire, non quello della pulizia.
    test('se fallisce anche l\'eliminazione arriva l\'errore originale', () async {
      archivio.erroreEliminazione =
          const JambException(TipoErrore.sconosciuto, 'Eliminazione fallita.');
      const errore = JambException(TipoErrore.permessoNegato, 'Operazione non consentita.');

      await expectLater(carica(scriviRiga: () => throw errore), throwsA(errore));
    });
  });
}
