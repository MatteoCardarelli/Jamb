import 'package:flutter/foundation.dart';
import '../entities/formazione.dart';

/// Contratto per iter formativo e Progetto del Capo.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IFormazioneRepository extends ChangeNotifier {
  /// Tappe compiute dall'utente connesso.
  Future<List<TappaCompiuta>> getMieTappe();

  /// Salva una tappa dell'utente connesso, o ne aggiorna la data.
  Future<void> salvaTappa(TappaCompiuta tappa);

  /// Rimuove una tappa dell'utente connesso.
  Future<void> rimuoviTappa(TappaFormativa tappa);

  /// Progetto del Capo dell'utente connesso.
  Future<ProgettoCapo> getMioProgetto();

  /// Salva il Progetto del Capo dell'utente connesso.
  Future<void> salvaMioProgetto(ProgettoCapo progetto);

  /// Capi del gruppo con il loro iter (per il Capo Gruppo).
  Future<List<CapoFormazione>> getCapiDelGruppo();

  /// Progetto del Capo di [userId] (per il Capo Gruppo).
  Future<ProgettoCapo> getProgettoDi(String userId);
}
