import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import '../../domain/repositories/auth_repository.dart';

/// Accesso con Supabase Auth. Il cambio di sessione lo rileva `SessionService`.
class SupabaseAuthRepository implements IAuthRepository {
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
}
