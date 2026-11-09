import 'package:flutter/material.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';

/// Stato della schermata di login: attesa e messaggio d'errore.
class LoginViewModel extends ChangeNotifier {
  final IAuthRepository _repository;

  LoginViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Prova ad accedere; un rifiuto o un problema di rete diventa [errorMessage].
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.accedi(email.trim(), password);
    } on JambException catch (e) {
      _errorMessage = e.messaggio;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
