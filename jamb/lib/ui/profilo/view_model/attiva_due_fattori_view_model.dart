import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/secondo_fattore.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';
import 'package:jamb/ui/auth/view_model/verifica_codice_view_model.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Attivazione della verifica in due passaggi: prepara il codice QR, poi la
/// conferma con il primo codice generato dall'app di autenticazione.
class AttivaDueFattoriViewModel extends ChangeNotifier
    with StatoCaricamentoMixin {
  final IAuthRepository _repository;

  AttivaDueFattoriViewModel(this._repository) {
    prepara();
  }

  AttivazioneSecondoFattore? _attivazione;

  /// Codice QR e chiave da mostrare (`null` finché non sono pronti).
  AttivazioneSecondoFattore? get attivazione => _attivazione;

  /// Prepara un nuovo codice QR (anche per «Riprova» dopo un errore).
  Future<void> prepara() => eseguiCaricamento(() async {
    _attivazione = await _repository.preparaDueFattori();
  });

  /// Conferma con il codice scritto; un errore si propaga alla View, che lo
  /// mostra e lascia riprovare con il codice successivo.
  Future<void> conferma(String testo) async {
    final attivazione = _attivazione;
    if (attivazione == null) return;
    final codice = codiceSecondoFattore(testo);
    if (codice == null) {
      throw const JambException(TipoErrore.datiNonValidi, erroreCodiceSeiCifre);
    }
    await _repository.confermaDueFattori(attivazione.idFattore, codice);
  }
}
