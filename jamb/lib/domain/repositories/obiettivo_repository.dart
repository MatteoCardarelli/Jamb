import '../../domain/entities/obiettivo.dart';

/// Contratto per l'accesso agli obiettivi educativi dell'unità.
abstract class IObiettivoRepository {
  /// Obiettivi educativi dell'unità attiva.
  Future<List<Obiettivo>> getObiettivi();

  /// Inserisce (id temporaneo non-UUID) o aggiorna (id UUID) l'[obiettivo].
  Future<void> salvaObiettivo(Obiettivo obiettivo);

  /// Elimina l'obiettivo con l'[id] indicato.
  Future<void> eliminaObiettivo(String id);
}
