/// Accesso all'app con le proprie credenziali.
abstract class IAuthRepository {
  /// Autentica l'utente; solleva una `JambException` se non ci riesce.
  Future<void> accedi(String email, String password);
}
