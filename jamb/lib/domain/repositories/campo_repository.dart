import 'package:flutter/foundation.dart';
import '../entities/campo.dart';

/// Contratto per la programmazione del campo dell'unità attiva.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class ICampoRepository extends ChangeNotifier {
  /// Campo dell'anno scout in corso; `null` se non è stato ancora creato.
  Future<Campo?> getCampo();

  /// Crea il campo dell'anno scout in corso.
  Future<void> creaCampo(String titolo);

  /// Salva titolo, luogo e date di [campo].
  Future<void> aggiornaCampo(Campo campo);

  /// Pattuglie del campo [campoId], dalla più vecchia.
  Future<List<Pattuglia>> getPattuglie(String campoId);

  /// Aggiunge una pattuglia al campo.
  Future<void> creaPattuglia(String campoId, String nome);

  /// Cambia il nome della pattuglia.
  Future<void> rinominaPattuglia(String id, String nome);

  /// Elimina la pattuglia con i suoi compiti.
  Future<void> eliminaPattuglia(String id);

  /// Compiti di tutte le [pattuglie], dal più vecchio.
  Future<List<CompitoCampo>> getCompiti(Iterable<String> pattuglie);

  /// Affida un nuovo compito alla pattuglia.
  Future<void> creaCompito(String pattugliaId, String titolo);

  /// Imposta lo stato di un compito.
  Future<void> impostaStato(String id, StatoCompito stato);

  /// Elimina un compito.
  Future<void> eliminaCompito(String id);
}
