import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/domain/entities/secondo_fattore.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import '../../domain/repositories/auth_repository.dart';

/// Accesso con Supabase Auth e verifica in due passaggi con codici TOTP
/// (`auth.mfa`). Il cambio di sessione lo rileva `SessionService`.
class SupabaseAuthRepository implements IAuthRepository {
  /// Supabase restituisce il codice QR come indirizzo `data:`; l'app
  /// disegna l'immagine SVG che contiene.
  static const _prefissoQr = 'data:image/svg+xml;utf-8,';

  @override
  Future<void> accedi(String email, String password) => eseguiSupabase(() async {
        try {
          await supabase.auth.signInWithPassword(email: email, password: password);
        } on AuthRetryableFetchException {
          rethrow; // è un problema di rete: lo traduce eseguiSupabase
        } on AuthException catch (e) {
          // Qui il motivo è il rifiuto delle credenziali, non una sessione scaduta.
          throw JambException(TipoErrore.nonAutenticato, e.message, causa: e);
        }
      });

  @override
  Future<void> verificaCodice(String codice) => eseguiSupabase(() async {
        // Non serve chiedere al server: la sessione appena aperta elenca già
        // i fattori dell'utente.
        final fattori = supabase.auth.currentUser?.factors ?? const <Factor>[];
        final totp = fattori.where(
          (f) => f.factorType == FactorType.totp && f.status == FactorStatus.verified,
        );
        if (totp.isEmpty) throw sessioneSenzaUtente;
        await _verifica(totp.first.id, codice);
      });

  @override
  Future<bool> dueFattoriAttivi() => eseguiSupabase(() async {
        final fattori = await supabase.auth.mfa.listFactors();
        return fattori.totp.isNotEmpty;
      });

  @override
  Future<AttivazioneSecondoFattore> preparaDueFattori() => eseguiSupabase(() async {
        final fattori = await supabase.auth.mfa.listFactors();
        for (final f in fattori.all) {
          if (f.factorType == FactorType.totp && f.status != FactorStatus.verified) {
            await supabase.auth.mfa.unenroll(f.id);
          }
        }
        final nuovo = await supabase.auth.mfa.enroll(issuer: 'Jamb');
        final totp = nuovo.totp;
        if (totp == null) {
          throw const JambException(
            TipoErrore.sconosciuto,
            'Il server non ha restituito il codice QR.',
          );
        }
        final qr = totp.qrCode;
        return AttivazioneSecondoFattore(
          idFattore: nuovo.id,
          qrSvg: qr.startsWith(_prefissoQr) ? qr.substring(_prefissoQr.length) : qr,
          segreto: totp.secret,
          uri: totp.uri,
        );
      });

  @override
  Future<void> confermaDueFattori(String idFattore, String codice) =>
      eseguiSupabase(() => _verifica(idFattore, codice));

  @override
  Future<void> disattivaDueFattori() => eseguiSupabase(() async {
        final fattori = await supabase.auth.mfa.listFactors();
        for (final f in fattori.totp) {
          await supabase.auth.mfa.unenroll(f.id);
        }
        // Aggiorna l'elenco dei fattori nella sessione salvata.
        await supabase.auth.refreshSession();
      });

  /// Verifica il [codice] per il fattore [idFattore]; un rifiuto diventa un
  /// messaggio sul codice, non una sessione scaduta.
  Future<void> _verifica(String idFattore, String codice) async {
    try {
      await supabase.auth.mfa.challengeAndVerify(factorId: idFattore, code: codice);
    } on AuthRetryableFetchException {
      rethrow;
    } on AuthException catch (e) {
      throw JambException(
        TipoErrore.datiNonValidi,
        'Codice non valido o scaduto: riprova con quello che vedi ora.',
        causa: e,
      );
    }
  }
}
