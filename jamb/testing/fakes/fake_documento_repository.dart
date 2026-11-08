import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';

/// Repository dei documenti finto (in memoria) per i test dei ViewModel.
///
/// [archivi] contiene i documenti di ciascun archivio; le scritture li
/// modificano e notificano come il repository reale. [erroreLettura] ed
/// [erroreScrittura], se impostati, vengono sollevati da letture e scritture.
class FakeDocumentoRepository extends ChangeNotifier implements IDocumentoRepository {
  final Map<ArchivioDocumenti, List<Documento>> archivi;
  final List<FileDaCaricare> caricati = [];
  JambException? erroreLettura;
  JambException? erroreScrittura;
  int _prossimoId = 1;

  FakeDocumentoRepository({Map<ArchivioDocumenti, List<Documento>>? archivi})
      : archivi = archivi ?? {};

  List<Documento> _di(ArchivioDocumenti a) => archivi.putIfAbsent(a, () => []);

  @override
  Future<List<Documento>> getContenuto(ArchivioDocumenti archivio, String? parentId) async {
    if (erroreLettura != null) throw erroreLettura!;
    return _di(archivio).where((d) => d.parentId == parentId).toList();
  }

  @override
  Future<List<Documento>> getRecenti({int quanti = 5}) async {
    if (erroreLettura != null) throw erroreLettura!;
    final file = _di(ArchivioDocumenti.driveBranca).where((d) => !d.isCartella).toList()
      ..sort((a, b) => b.ultimaModifica.compareTo(a.ultimaModifica));
    return file.take(quanti).toList();
  }

  @override
  Future<void> creaCartella(ArchivioDocumenti archivio, String nome, String? parentId) =>
      _scrivi(() => _di(archivio).add(Documento(
            id: 'cartella-${_prossimoId++}',
            nome: nome,
            tipo: TipoDocumento.cartella,
            parentId: parentId,
            ultimaModifica: DateTime(2026, 11, 7),
          )));

  @override
  Future<Documento> caricaFile(ArchivioDocumenti archivio, FileDaCaricare file, String? parentId) async {
    late Documento creato;
    await _scrivi(() {
      caricati.add(file);
      creato = Documento(
        id: 'file-${_prossimoId++}',
        nome: file.nome,
        tipo: TipoDocumento.pdf,
        parentId: parentId,
        ultimaModifica: DateTime(2026, 11, 7),
        percorsoFile: 'archivio/${file.nome}',
      );
      _di(archivio).add(creato);
    });
    return creato;
  }

  @override
  Future<void> rinomina(Documento documento, String nome) => _scrivi(() {
        for (final lista in archivi.values) {
          final i = lista.indexWhere((d) => d.id == documento.id);
          if (i >= 0) lista[i] = lista[i].copyWith(nome: nome);
        }
      });

  @override
  Future<void> elimina(ArchivioDocumenti archivio, Documento documento) => _scrivi(() {
        final via = {documento.id, ...discendenti(_di(archivio), documento.id).map((d) => d.id)};
        _di(archivio).removeWhere((d) => via.contains(d.id));
      });

  @override
  Future<void> eliminaTutti(ArchivioDocumenti archivio, List<Documento> documenti) => _scrivi(() {
        final via = {
          for (final d in documenti) ...[d.id, ...discendenti(_di(archivio), d.id).map((x) => x.id)],
        };
        _di(archivio).removeWhere((d) => via.contains(d.id));
      });

  @override
  Future<void> sposta(List<Documento> documenti, String? destinazione) => _scrivi(() {
        final ids = {for (final d in documenti) d.id};
        for (final lista in archivi.values) {
          for (var i = 0; i < lista.length; i++) {
            if (!ids.contains(lista[i].id)) continue;
            final d = lista[i];
            // Si ricrea il documento: copyWith non può azzerare la cartella.
            lista[i] = Documento(
              id: d.id,
              nome: d.nome,
              tipo: d.tipo,
              parentId: destinazione,
              ultimaModifica: d.ultimaModifica,
              dimensioni: d.dimensioni,
              percorsoFile: d.percorsoFile,
            );
          }
        }
      });

  @override
  Future<List<Documento>> getCartelle(ArchivioDocumenti archivio) async {
    if (erroreLettura != null) throw erroreLettura!;
    return _di(archivio).where((d) => d.isCartella).toList();
  }

  @override
  Future<String> urlFile(Documento documento) async {
    if (erroreLettura != null) throw erroreLettura!;
    return 'https://archivio.test/${documento.percorsoFile}';
  }

  Future<void> _scrivi(void Function() scrittura) async {
    if (erroreScrittura != null) throw erroreScrittura!;
    scrittura();
    notifyListeners();
  }
}
