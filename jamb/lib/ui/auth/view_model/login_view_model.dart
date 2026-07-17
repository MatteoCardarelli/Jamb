import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamb/core/supabase_client.dart';

/// Stato della schermata di login: gestisce la chiamata di autenticazione
/// a Supabase e l'eventuale messaggio d'errore.
class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Errore di connessione. Riprova.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}