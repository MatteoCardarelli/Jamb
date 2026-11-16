import 'package:jamb/domain/entities/secondo_fattore.dart';

/// Accesso all'app con le proprie credenziali e verifica in due passaggi.
abstract class IAuthRepository {
  /// Autentica l'utente; solleva una `JambException` se non ci riesce.
  Future<void> accedi(String email, String password);

  /// Completa l'accesso di chi ha la verifica in due passaggi con il
  /// [codice] di 6 cifre dell'app di autenticazione.
  Future<void> verificaCodice(String codice);

  /// Se l'utente connesso ha attivato la verifica in due passaggi.
  Future<bool> dueFattoriAttivi();

  /// Prepara la verifica in due passaggi, da confermare con
  /// [confermaDueFattori]; elimina le attivazioni lasciate a metà.
  Future<AttivazioneSecondoFattore> preparaDueFattori();

  /// Attiva la verifica in due passaggi con il primo [codice] generato
  /// dall'app di autenticazione per il fattore [idFattore].
  Future<void> confermaDueFattori(String idFattore, String codice);

  /// Disattiva la verifica in due passaggi: dal prossimo accesso basta la
  /// password.
  Future<void> disattivaDueFattori();
}
