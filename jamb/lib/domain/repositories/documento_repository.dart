import 'package:flutter/foundation.dart';
import '../entities/documento.dart';
import '../entities/file_da_caricare.dart';

/// Contratto per gli archivi di documenti (drive e librerie), ciascuno un
/// albero di cartelle e file.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IDocumentoRepository extends ChangeNotifier {
  /// Contenuto diretto (cartelle e file) di una cartella di [archivio];
  /// [parentId] `null` indica la radice.
  Future<List<Documento>> getContenuto(ArchivioDocumenti archivio, String? parentId);

  /// Ultimi file modificati nel Drive di Branca dell'unità attiva.
  Future<List<Documento>> getRecenti({int quanti = 5});

  /// Crea la cartella [nome] in [archivio], dentro [parentId] (o alla radice).
  Future<void> creaCartella(ArchivioDocumenti archivio, String nome, String? parentId);

  /// Archivia [file] in [archivio], dentro [parentId] (o alla radice), e
  /// restituisce il documento creato.
  Future<Documento> caricaFile(ArchivioDocumenti archivio, FileDaCaricare file, String? parentId);

  /// Cambia il nome di [documento].
  Future<void> rinomina(Documento documento, String nome);

  /// Elimina [documento]; una cartella con tutto il suo contenuto.
  Future<void> elimina(ArchivioDocumenti archivio, Documento documento);

  /// Elimina tutti i [documenti] in un'unica scrittura, le cartelle con il
  /// loro contenuto.
  Future<void> eliminaTutti(ArchivioDocumenti archivio, List<Documento> documenti);

  /// Sposta i [documenti] nella cartella [destinazione] (la radice se `null`)
  /// dello stesso archivio, in un'unica scrittura.
  Future<void> sposta(List<Documento> documenti, String? destinazione);

  /// Tutte le cartelle di [archivio], a qualunque profondità.
  Future<List<Documento>> getCartelle(ArchivioDocumenti archivio);

  /// URL temporaneo per aprire il file [documento].
  Future<String> urlFile(Documento documento);
}
