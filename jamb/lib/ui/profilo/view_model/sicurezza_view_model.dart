import 'package:flutter/foundation.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Sezione «Sicurezza» del profilo: se la verifica in due passaggi è attiva.
class SicurezzaViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IAuthRepository _repository;

  SicurezzaViewModel(this._repository) {
    carica();
  }

  bool _dueFattori = false;

  /// Se a ogni accesso, dopo la password, serve il codice dell'app.
  bool get dueFattori => _dueFattori;

  /// Rilegge lo stato dal server (anche dopo l'attivazione).
  Future<void> carica() => eseguiCaricamento(() async {
    _dueFattori = await _repository.dueFattoriAttivi();
  });

  /// Disattiva la verifica in due passaggi; un errore si propaga alla View.
  Future<void> disattiva() async {
    await _repository.disattivaDueFattori();
    _dueFattori = false;
    notifyListeners();
  }
}
