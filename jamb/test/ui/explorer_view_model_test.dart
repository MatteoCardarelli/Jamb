import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';
import 'package:jamb/ui/explorer/view_model/explorer_view_model.dart';
import '../../testing/fakes/fake_documento_repository.dart';

Future<void> _attendi() => Future.delayed(Duration.zero);

Documento _doc(String id, {String? padre, bool cartella = false, int? dimensioni, String? percorso}) =>
    Documento(
      id: id,
      nome: id,
      tipo: cartella ? TipoDocumento.cartella : TipoDocumento.pdf,
      parentId: padre,
      ultimaModifica: DateTime(2026, 11, 1),
      dimensioni: dimensioni,
      percorsoFile: percorso,
    );

void main() {
  late FakeDocumentoRepository repo;

  setUp(() {
    repo = FakeDocumentoRepository(archivi: {
      ArchivioDocumenti.driveBranca: [
        _doc('verbale.pdf', percorso: 'g/u/1.pdf', dimensioni: 2048),
        _doc('Uscite', cartella: true),
        _doc('menu.pdf', padre: 'Uscite', percorso: 'g/u/2.pdf'),
      ],
    });
  });

  ExplorerViewModel radice() => ExplorerViewModel(
        repository: repo,
        archivio: ArchivioDocumenti.driveBranca,
        titolo: 'Drive di Branca',
      );

  group('ExplorerViewModel', () {
    test('mostra solo il livello corrente, cartelle prima', () async {
      final vm = radice();
      await _attendi();
      expect(vm.contenutoFiltrato.map((d) => d.id), ['Uscite', 'verbale.pdf']);
    });

    test('il sottotitolo distingue cartelle, file e file senza contenuto', () async {
      final vm = radice();
      expect(vm.sottotitolo(_doc('Uscite', cartella: true)), 'Cartella');
      expect(vm.sottotitolo(_doc('a.pdf', percorso: 'p', dimensioni: 2048)), 'PDF · 2 KB');
      expect(vm.sottotitolo(_doc('vecchio.pdf')), 'Senza contenuto');
    });

    test('una nuova cartella compare dopo il salvataggio', () async {
      final vm = radice();
      await _attendi();

      await vm.creaCartella('Verbali');
      await _attendi();

      expect(vm.contenutoFiltrato.map((d) => d.nome), contains('Verbali'));
    });

    test('un nome non valido non arriva al repository', () async {
      final vm = radice();
      await _attendi();

      expect(() => vm.creaCartella('Uscite/Campo'), throwsA(isA<JambException>()));
      expect(() => vm.rinomina(repo.archivi[ArchivioDocumenti.driveBranca]!.first, '  '),
          throwsA(isA<JambException>()));
      expect(repo.archivi[ArchivioDocumenti.driveBranca], hasLength(3));
    });

    test('il file caricato va nella cartella aperta', () async {
      final vm = ExplorerViewModel(
        repository: repo,
        archivio: ArchivioDocumenti.driveBranca,
        titolo: 'Uscite',
        parentId: 'Uscite',
      );
      await _attendi();

      await vm.caricaFile(FileDaCaricare(nome: 'permessi.pdf', byte: Uint8List(10)));
      await _attendi();

      expect(vm.contenutoFiltrato.map((d) => d.nome), ['menu.pdf', 'permessi.pdf']);
    });

    test('eliminare una cartella toglie anche il suo contenuto', () async {
      final vm = radice();
      await _attendi();

      await vm.elimina(vm.contenutoFiltrato.first);
      await _attendi();

      expect(repo.archivi[ArchivioDocumenti.driveBranca]!.map((d) => d.id), ['verbale.pdf']);
    });

    test('un errore di lettura porta allo stato errore', () async {
      repo.erroreLettura = const JambException(TipoErrore.rete, 'Connessione assente.');
      final vm = radice();
      await _attendi();
      expect(vm.stato, StatoCaricamento.errore);
    });
  });
}
