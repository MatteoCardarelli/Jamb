import 'package:flutter/foundation.dart';
import '../entities/campo.dart';
import '../entities/sottogruppi.dart';

/// Contratto per l'organizzazione dei campi dell'unità attiva.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class ICampoRepository extends ChangeNotifier {
  /// Campi e uscite dell'unità, dal più recente.
  Future<List<Campo>> getCampi();

  /// Campo [id]; `null` se non esiste più.
  Future<Campo?> getCampo(String id);

  /// Crea un campo di [tipo] nell'unità attiva e lo restituisce.
  Future<Campo> creaCampo(TipoCampo tipo, String titolo);

  /// Salva titolo, luogo e date di [campo].
  Future<void> aggiornaCampo(Campo campo);

  /// Elimina il campo con pattuglie, compiti e contatti.
  Future<void> eliminaCampo(String id);

  /// Capi dell'unità attiva, tra cui scegliere i componenti delle pattuglie.
  Future<List<MembroUnita>> getStaff();

  /// Pattuglie del campo [campoId] con i loro componenti, dalla più vecchia.
  Future<List<Pattuglia>> getPattuglie(String campoId);

  /// Aggiunge una pattuglia al campo.
  Future<void> creaPattuglia(String campoId, String nome);

  /// Cambia il nome della pattuglia.
  Future<void> rinominaPattuglia(String id, String nome);

  /// Sostituisce i componenti della pattuglia, in un'unica transazione.
  Future<void> salvaMembriPattuglia(String id, Set<String> membri);

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

  /// Contatti telefonici del campo [campoId], dal più vecchio.
  Future<List<ContattoCampo>> getContatti(String campoId);

  /// Aggiunge un contatto al campo.
  Future<void> creaContatto(String campoId, String etichetta, String telefono);

  /// Elimina un contatto.
  Future<void> eliminaContatto(String id);
}
