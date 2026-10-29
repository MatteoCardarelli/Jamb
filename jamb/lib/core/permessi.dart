/// Ruoli in ordine crescente di autorità, nello stesso ordine di `ruolo_enum`
/// nel database: le policy RLS li confrontano con `>=`.
const List<String> gerarchiaRuoli = [
  'RAGAZZO',
  'VICE_CAPO_SQ',
  'CAPO_SQ',
  'AIUTO_CAPO',
  'CAPO_UNITA',
  'CAPO_GRUPPO',
];

/// Cosa può fare l'utente nell'unità attiva, ricavato dal suo ruolo.
///
/// Rispecchia le policy RLS per non mostrare azioni che il database
/// rifiuterebbe; la sicurezza resta comunque nelle RLS.
///
/// Oggi tutte le scritture operative (ragazzi, cassa, eventi, Programma
/// d'Unità, documenti) richiedono `AIUTO_CAPO`, la stessa soglia per accedere
/// all'area capi: per quelle basta [puoUsareAreaCapi]. Un permesso dedicato
/// si aggiunge quando una policy usa una soglia diversa.
class Permessi {
  /// Ruolo nell'unità attiva (`null` se non determinabile).
  final String? ruolo;

  /// `CAPO_GRUPPO` in almeno una membership attiva, come `is_capo_gruppo()`
  /// nel database: vale su tutte le unità del gruppo.
  final bool capoGruppo;

  const Permessi({this.ruolo, this.capoGruppo = false});

  /// Nessun permesso: utente non autenticato o senza ruolo.
  static const nessuno = Permessi();

  /// Accesso alle schermate dei capi (letture e scritture: `AIUTO_CAPO`).
  /// I ruoli da ragazzo non vedono alcun dato finché non avranno un'area propria.
  bool get puoUsareAreaCapi => _almeno('AIUTO_CAPO');

  /// Cambiare ruolo e squadriglia di un ragazzo
  /// (policy `memberships_insert`/`memberships_update`: `CAPO_UNITA`).
  bool get puoCambiareRuoloESquadriglia => _almeno('CAPO_UNITA');

  bool _almeno(String minimo) =>
      capoGruppo || _livello(ruolo) >= _livello(minimo);

  /// Posizione nella gerarchia; un ruolo sconosciuto non concede nulla.
  static int _livello(String? ruolo) =>
      ruolo == null ? -1 : gerarchiaRuoli.indexOf(ruolo);
}
