import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/evento.dart';

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

  /// Incarico trasversale, indipendente dal ruolo nelle unità (come
  /// `is_assistente_ecclesiastico()` nel database).
  final bool assistenteEcclesiastico;

  const Permessi({this.ruolo, this.capoGruppo = false, this.assistenteEcclesiastico = false});

  /// Nessun permesso: utente non autenticato o senza ruolo.
  static const nessuno = Permessi();

  /// Accesso alle schermate dei capi (letture e scritture: `AIUTO_CAPO`).
  /// I ruoli da ragazzo non vedono alcun dato finché non avranno un'area propria.
  bool get puoUsareAreaCapi => _almeno('AIUTO_CAPO');

  /// Cambiare ruolo e squadriglia di un ragazzo
  /// (policy `memberships_insert`/`memberships_update`: `CAPO_UNITA`).
  bool get puoCambiareRuoloESquadriglia => _almeno('CAPO_UNITA');

  /// Caricare, rinominare ed eliminare i documenti di Metodo e Statuto e
  /// Modulistica (`posso_scrivere_libreria`: `CAPO_UNITA`, decisione
  /// dell'utente del 2026-11-07). Il database guarda tutte le membership,
  /// qui solo l'unità attiva: la UI può nascondere un'azione permessa, mai
  /// mostrarne una vietata.
  bool get puoGestireLibreria => _almeno('CAPO_UNITA');

  /// Modificare o eliminare un evento di [livello]: tutti i capi vedono gli
  /// eventi del gruppo, ma scrivono solo su quelli della propria unità e della
  /// Co.Ca. (`events_update`/`events_delete`: `posso_usare_unita`); il Capo
  /// Gruppo su tutti.
  bool puoModificareEvento(LivelloEvento livello) => switch (livello) {
        LivelloEvento.unita || LivelloEvento.coca => puoUsareAreaCapi,
        LivelloEvento.altraUnita || LivelloEvento.gruppo => capoGruppo,
      };

  /// Vedere il bilancio consolidato del gruppo: solo il Capo Gruppo legge le
  /// transazioni di tutte le unità (`transactions_select`: `is_capo_gruppo()`).
  bool get puoVedereBilancioGruppo => capoGruppo;

  /// Modificare l'archivio [archivio]: i drive come le altre scritture
  /// operative, le librerie solo da Capo Unità in su.
  bool puoModificare(ArchivioDocumenti archivio) {
    if (archivio.isLibreria) return puoGestireLibreria;
    return puoUsareAreaCapi ||
        (archivio == ArchivioDocumenti.driveCoca && assistenteEcclesiastico);
  }

  /// Vedere iter formativo e Progetto del Capo di tutta la Co.Ca.
  /// (`iter_select`, `progetti_select`: `sono_capo_gruppo_di`).
  bool get puoVedereFormazioneCoca => capoGruppo;

  /// Scrivere il Progetto Educativo di Gruppo (`peg_*`: `is_capo_gruppo()`).
  bool get puoScriverePeg => capoGruppo;

  /// Nominare l'Assistente Ecclesiastico (`incarichi_insert`: `is_capo_gruppo()`).
  bool get puoNominareAssistente => capoGruppo;

  bool _almeno(String minimo) =>
      capoGruppo || _livello(ruolo) >= _livello(minimo);

  /// Posizione nella gerarchia; un ruolo sconosciuto non concede nulla.
  static int _livello(String? ruolo) =>
      ruolo == null ? -1 : gerarchiaRuoli.indexOf(ruolo);
}
