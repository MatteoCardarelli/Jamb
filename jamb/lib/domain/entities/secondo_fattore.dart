/// Dati per attivare la verifica in due passaggi: l'app di autenticazione
/// (Google Authenticator, Microsoft Authenticator, …) li legge dal codice QR
/// o dalla chiave scritta a mano, poi genera un codice di 6 cifre ogni 30
/// secondi.
class AttivazioneSecondoFattore {
  /// Identificativo del fattore, da confermare con il primo codice.
  final String idFattore;

  /// Immagine SVG del codice QR.
  final String qrSvg;

  /// Chiave da inserire a mano se non si può inquadrare il codice QR.
  final String segreto;

  /// Indirizzo `otpauth://` che apre direttamente l'app di autenticazione.
  final String uri;

  const AttivazioneSecondoFattore({
    required this.idFattore,
    required this.qrSvg,
    required this.segreto,
    required this.uri,
  });
}

/// Il codice dell'app di autenticazione senza spazi (es. «123 456» incollato),
/// oppure `null` se non sono esattamente 6 cifre.
String? codiceSecondoFattore(String testo) {
  final pulito = testo.replaceAll(RegExp(r'\s'), '');
  return RegExp(r'^\d{6}$').hasMatch(pulito) ? pulito : null;
}
