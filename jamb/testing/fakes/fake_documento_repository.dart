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
  Future<void> caricaFile(ArchivioDocumenti archivio, FileDaCaricare file, String? parentId) =>
      _scrivi(() {
        caricati.add(file);
        _di(archivio).add(Documento(
          id: 'file-${_prossimoId++}',
          nome: file.nome,
          tipo: TipoDocumento.pdf,
          parentId: parentId,
          ultimaModifica: DateTime(2026, 11, 7),
          percorsoFile: 'archivio/${file.nome}',
        ));
      });

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
