import 'package:flutter/foundation.dart';
import '../entities/pillola.dart';

/// Contratto per le pillole del metodo e gli spunti di spiritualità.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IPillolaRepository extends ChangeNotifier {
  /// Pillole di [tipo]: per il metodo quelle comuni e del gruppo per la branca
  /// dell'unità attiva, per la spiritualità quelle del gruppo.
  Future<List<Pillola>> getPillole({TipoPillola tipo = TipoPillola.metodo});

  /// Aggiunge una pillola del gruppo di [tipo].
  Future<void> crea(String testo, {TipoPillola tipo = TipoPillola.metodo});

  /// Cambia il testo della pillola [id].
  Future<void> aggiorna(String id, String testo);

  /// Elimina la pillola [id].
  Future<void> elimina(String id);
}
