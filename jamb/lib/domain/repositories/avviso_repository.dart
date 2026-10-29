import 'package:flutter/foundation.dart';
import '../../domain/entities/avviso.dart';

/// Contratto per l'accesso alla bacheca avvisi dell'unità attiva.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IAvvisoRepository extends ChangeNotifier {
  /// Avvisi dell'unità attiva, ciascuno con lo stato di lettura dell'utente.
  Future<List<Avviso>> getAvvisi();

  /// Pubblica [avviso] nell'unità attiva, a nome dell'utente loggato.
  /// Data di pubblicazione, autore e stato di lettura sono ignorati.
  Future<void> creaAvviso(Avviso avviso);

  /// Aggiorna oggetto, testo e destinatari dell'avviso con lo stesso id.
  Future<void> aggiornaAvviso(Avviso avviso);

  /// Elimina l'avviso con l'[id] indicato.
  Future<void> eliminaAvviso(String id);

  /// Registra che l'utente ha letto l'avviso con l'[id] indicato.
  Future<void> segnaComeLetto(String id);
}
