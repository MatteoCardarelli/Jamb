import 'package:flutter/foundation.dart';
import '../../domain/entities/transazione.dart';

/// Contratto per l'accesso alle transazioni di cassa.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class ITransazioneRepository extends ChangeNotifier {
  /// Transazioni dell'unità attiva, ordinate per data decrescente.
  Future<List<Transazione>> getTransazioni();

  /// Inserisce (id temporaneo non-UUID) o aggiorna (id UUID) la [transazione].
  Future<void> salvaTransazione(Transazione transazione);

  /// Elimina la transazione con l'[id] indicato.
  Future<void> eliminaTransazione(String id);
}
