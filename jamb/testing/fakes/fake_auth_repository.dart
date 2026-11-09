import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';

/// Accesso finto: registra le credenziali ricevute e, se impostato, solleva
/// [errore].
class FakeAuthRepository implements IAuthRepository {
  JambException? errore;
  String? emailRicevuta;

  @override
  Future<void> accedi(String email, String password) async {
    emailRicevuta = email;
    if (errore != null) throw errore!;
  }
}
