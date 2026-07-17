import '../entities/documento.dart';

/// Contratto per l'accesso all'albero dei documenti (cartelle e file).
abstract class IDocumentoRepository {
  /// Contenuto diretto (cartelle + file) di una cartella.
  /// [parentId] `null` indica la radice dell'unità.
  Future<List<Documento>> getContenuto(String? parentId);
}
