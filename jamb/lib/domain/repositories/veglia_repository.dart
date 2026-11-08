import 'package:flutter/foundation.dart';
import '../entities/veglia.dart';

/// Contratto per le veglie del gruppo.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IVegliaRepository extends ChangeNotifier {
  /// Veglie del gruppo, dalla più recente.
  Future<List<Veglia>> getVeglie();

  /// Crea la veglia se non ha un id, altrimenti la aggiorna.
  Future<void> salva(Veglia veglia);

  /// Elimina la veglia [id].
  Future<void> elimina(String id);
}
