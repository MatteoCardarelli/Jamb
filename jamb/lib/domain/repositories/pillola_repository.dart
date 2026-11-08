import 'package:flutter/foundation.dart';
import '../entities/pillola.dart';

/// Contratto per le pillole del metodo della branca dell'unità attiva.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IPillolaRepository extends ChangeNotifier {
  /// Pillole della branca: quelle comuni e quelle del gruppo.
  Future<List<Pillola>> getPillole();

  /// Aggiunge una pillola del gruppo per la branca dell'unità attiva.
  Future<void> crea(String testo);

  /// Cambia il testo della pillola [id].
  Future<void> aggiorna(String id, String testo);

  /// Elimina la pillola [id].
  Future<void> elimina(String id);
}
