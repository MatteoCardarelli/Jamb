/// Avviso della bacheca dell'unità, scritto da un capo per gli altri capi.
///
/// È indirizzato a tutta l'unità oppure a una sola squadriglia.
class Avviso {
  final String id;

  /// Oggetto dell'avviso.
  final String titolo;

  /// Testo del messaggio.
  final String contenuto;

  final DateTime dataPubblicazione;

  /// Nome e cognome di chi l'ha scritto (vuoto se non è leggibile).
  final String autore;

  /// Squadriglia destinataria; `null` se l'avviso è per tutta l'unità.
  final String? squadriglia;

  /// `true` se l'utente l'ha già aperto, o se l'ha scritto lui.
  final bool letto;

  const Avviso({
    required this.id,
    required this.titolo,
    required this.contenuto,
    required this.dataPubblicazione,
    this.autore = '',
    this.squadriglia,
    this.letto = false,
  });

  /// `true` se l'avviso è indirizzato a tutta l'unità.
  bool get perTuttaLUnita => squadriglia == null;
}
