import 'package:jamb/domain/entities/secondo_fattore.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';

/// Accesso finto: registra le credenziali e i codici ricevuti e, se
/// impostato, solleva [errore]. La verifica in due passaggi accetta solo
/// [codiceGiusto].
class FakeAuthRepository implements IAuthRepository {
  JambException? errore;
  String? emailRicevuta;

  /// Codice che l'«app di autenticazione» mostra in questo momento.
  String codiceGiusto = '123456';

  /// Se la verifica in due passaggi è attiva.
  bool dueFattori = false;

  /// Codici ricevuti, nell'ordine.
  final List<String> codiciRicevuti = [];

  /// Quante volte è stata preparata un'attivazione.
  int preparazioni = 0;

  static const attivazione = AttivazioneSecondoFattore(
    idFattore: 'fattore-1',
    qrSvg: '<svg xmlns="http://www.w3.org/2000/svg"/>',
    segreto: 'JBSWY3DPEHPK3PXP',
    uri: 'otpauth://totp/Jamb:capo@test.it?secret=JBSWY3DPEHPK3PXP',
  );

  @override
  Future<void> accedi(String email, String password) async {
    emailRicevuta = email;
    if (errore != null) throw errore!;
  }

  @override
  Future<void> verificaCodice(String codice) async {
    _controlla(codice);
  }

  @override
  Future<bool> dueFattoriAttivi() async {
    if (errore != null) throw errore!;
    return dueFattori;
  }

  @override
  Future<AttivazioneSecondoFattore> preparaDueFattori() async {
    if (errore != null) throw errore!;
    preparazioni++;
    return attivazione;
  }

  @override
  Future<void> confermaDueFattori(String idFattore, String codice) async {
    _controlla(codice);
    dueFattori = true;
  }

  @override
  Future<void> disattivaDueFattori() async {
    if (errore != null) throw errore!;
    dueFattori = false;
  }

  void _controlla(String codice) {
    codiciRicevuti.add(codice);
    if (errore != null) throw errore!;
    if (codice != codiceGiusto) {
      throw const JambException(TipoErrore.datiNonValidi, 'Codice non valido');
    }
  }
}
