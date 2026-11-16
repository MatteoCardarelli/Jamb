import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/secondo_fattore.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';

/// Messaggio per un codice che non ha 6 cifre.
const erroreCodiceSeiCifre = 'Il codice è di 6 cifre.';

/// Secondo passaggio dell'accesso: il codice dell'app di autenticazione.
///
/// Se il codice è giusto la sessione passa al livello `aal2` e
/// `SessionService` carica l'utente: questa schermata viene sostituita.
class VerificaCodiceViewModel extends ChangeNotifier {
  final IAuthRepository _repository;

  VerificaCodiceViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Verifica il codice scritto; un codice malformato non raggiunge il server.
  Future<void> verifica(String testo) async {
    final codice = codiceSecondoFattore(testo);
    if (codice == null) {
      _errorMessage = erroreCodiceSeiCifre;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.verificaCodice(codice);
    } on JambException catch (e) {
      _errorMessage = e.messaggio;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
