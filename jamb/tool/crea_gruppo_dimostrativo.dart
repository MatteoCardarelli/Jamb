// Crea il gruppo dimostrativo di Jamb, «Valle Serena 1»: un gruppo
// inventato ma credibile, da mostrare a chi prova l'app senza usare dati
// veri di minori. Tutti i nomi sono inventati e i telefoni sono finti.
//
// Contiene Branco, Reparto e Clan con capi e ragazzi, riunioni passate e
// future con l'appello fatto, cassa e ricevute, avvisi, Programma d'Unità
// collegato al PEG, un campo invernale organizzato e l'iter formativo dei
// capi. Le date sono calcolate dal giorno in cui si lancia lo script.
//
// Serve la chiave service_role, che scavalca le RLS: va passata solo
// nell'ambiente, mai scritta in un file. Da jamb/:
//
//   SUPABASE_URL=https://<ref>.supabase.co \
//   SUPABASE_SERVICE_ROLE_KEY=... \
//   JAMB_PASSWORD_DEMO=... \
//   JAMB_CONFERMA_PROGETTO=<ref> \
//   dart run tool/crea_gruppo_dimostrativo.dart
//
// Facoltativo: JAMB_DOMINIO_DEMO (predefinito demo.jamb.test), il dominio
// delle email degli account; nessuna email viene inviata.
//
// Si può rilanciare: gruppo, unità e persone esistenti vengono riusati, e
// ogni contenuto (schede, eventi, cassa, avvisi…) si crea una volta sola,
// anche se un lancio precedente si è interrotto a metà.
import 'dart:io';
import 'dart:math';

import 'package:jamb/domain/entities/anno_scout.dart';

import 'supabase_admin.dart';

const String _nomeGruppo = 'Valle Serena 1';
const String _zona = 'Zona dei Colli';

const Map<String, String> _unita = {
  'COCA': 'Comunità Capi Valle Serena 1',
  'LC': 'Branco Fiore Rosso',
  'EG': 'Reparto Stella Polare',
  'RS': 'Clan Sentiero Alto',
};

/// Squadriglie (E/G) e sestiglie (L/C), con l'urlo.
const Map<String, Map<String, String>> _squadriglie = {
  'EG': {
    'Aquile': 'Aquile, in alto!',
    'Volpi': 'Volpi, svelte e furbe!',
    'Pantere': 'Pantere, sempre pronte!',
  },
  'LC': {'Bianchi': '', 'Neri': '', 'Grigi': ''},
};

/// Un capo: [chiave] diventa la parte locale dell'email.
class _Capo {
  final String chiave;
  final String nome;
  final String cognome;
  final String branca;
  final String ruolo;

  const _Capo(this.chiave, this.nome, this.cognome, this.branca, this.ruolo);
}

const List<_Capo> _capi = [
  _Capo('capogruppo', 'Chiara', 'Ferretti', 'COCA', 'CAPO_GRUPPO'),
  _Capo('akela', 'Davide', 'Marchi', 'LC', 'CAPO_UNITA'),
  _Capo('capo.reparto', 'Elena', 'Riva', 'EG', 'CAPO_UNITA'),
  _Capo('aiuto.reparto', 'Marco', 'Sartori', 'EG', 'AIUTO_CAPO'),
  _Capo('capo.clan', 'Paolo', 'Greco', 'RS', 'CAPO_UNITA'),
];

/// L'Assistente Ecclesiastico non ha unità: è un incarico del gruppo.
const _Capo _assistente = _Capo('assistente', 'don Luca', 'Moretti', '', '');

/// Un ragazzo. [eta] è l'età di oggi; il resto descrive la sua scheda.
class _Ragazzo {
  final String nome;
  final String cognome;
  final String branca;
  final int eta;
  final String? squadriglia;
  final String ruolo;
  final String? allergie;

  const _Ragazzo(
    this.nome,
    this.cognome,
    this.branca,
    this.eta,
    this.squadriglia, [
    this.ruolo = 'RAGAZZO',
    this.allergie,
  ]);
}

const List<_Ragazzo> _ragazzi = [
  // Reparto: tre squadriglie da cinque.
  _Ragazzo('Tommaso', 'Galli', 'EG', 16, 'Aquile', 'CAPO_SQ'),
  _Ragazzo(
    'Alice',
    'Fontana',
    'EG',
    15,
    'Aquile',
    'VICE_CAPO_SQ',
    "Allergia alle arachidi: ha sempre con sé l'autoiniettore di adrenalina.",
  ),
  _Ragazzo('Matteo', 'Rinaldi', 'EG', 14, 'Aquile'),
  _Ragazzo('Giorgia', 'Caruso', 'EG', 13, 'Aquile'),
  _Ragazzo('Samuele', 'Testa', 'EG', 12, 'Aquile'),
  _Ragazzo('Beatrice', 'Lombardi', 'EG', 16, 'Volpi', 'CAPO_SQ'),
  _Ragazzo('Riccardo', 'Barbieri', 'EG', 15, 'Volpi', 'VICE_CAPO_SQ'),
  _Ragazzo('Sofia', 'Mancini', 'EG', 14, 'Volpi'),
  _Ragazzo(
    'Pietro',
    'Colombo',
    'EG',
    13,
    'Volpi',
    'RAGAZZO',
    'Celiachia: pasti senza glutine.',
  ),
  _Ragazzo('Emma', 'Ricci', 'EG', 12, 'Volpi'),
  _Ragazzo('Lorenzo', 'Gatti', 'EG', 16, 'Pantere', 'CAPO_SQ'),
  _Ragazzo('Martina', 'Pellegrini', 'EG', 15, 'Pantere', 'VICE_CAPO_SQ'),
  _Ragazzo('Francesco', 'Vitale', 'EG', 14, 'Pantere'),
  _Ragazzo('Aurora', 'Serra', 'EG', 13, 'Pantere'),
  _Ragazzo('Leonardo', 'Bianco', 'EG', 12, 'Pantere'),
  // Branco: tre sestiglie.
  _Ragazzo('Edoardo', 'Fabbri', 'LC', 11, 'Bianchi', 'CAPO_SQ'),
  _Ragazzo('Ginevra', 'Monti', 'LC', 10, 'Bianchi'),
  _Ragazzo('Nicolò', 'Valentini', 'LC', 9, 'Bianchi'),
  _Ragazzo(
    'Viola',
    'Ferrara',
    'LC',
    11,
    'Neri',
    'CAPO_SQ',
    'Asma lieve: inalatore nello zaino.',
  ),
  _Ragazzo('Gabriele', 'Morelli', 'LC', 9, 'Neri'),
  _Ragazzo('Anna', 'Grassi', 'LC', 8, 'Neri'),
  _Ragazzo('Diego', 'Rizzo', 'LC', 11, 'Grigi', 'CAPO_SQ'),
  _Ragazzo('Chiara', 'De Luca', 'LC', 10, 'Grigi'),
  _Ragazzo('Andrea', 'Longo', 'LC', 8, 'Grigi'),
  // Clan.
  _Ragazzo(
    'Giacomo',
    'Ferri',
    'RS',
    19,
    null,
    'RAGAZZO',
    'Intolleranza al lattosio.',
  ),
  _Ragazzo('Irene', 'Marino', 'RS', 18, null),
  _Ragazzo('Federico', 'Costa', 'RS', 18, null),
  _Ragazzo('Elisa', 'Martini', 'RS', 17, null),
  _Ragazzo('Michele', 'Santoro', 'RS', 17, null),
];

final Random _caso = Random(2026);

/// UUID casuale (v4), per legare le date di un evento che si ripete.
String _uuid() {
  final b = List<int>.generate(16, (_) => _caso.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

String _giorno(DateTime d) => d.toIso8601String().split('T').first;
String _istante(DateTime d) =>
    DateTime(d.year, d.month, d.day, d.hour, d.minute).toIso8601String();

/// Il sabato della settimana di [oggi] spostato di [settimane], all'ora [ora].
DateTime _sabato(DateTime oggi, int settimane, int ora) {
  final base = DateTime(
    oggi.year,
    oggi.month,
    oggi.day,
  ).add(Duration(days: (DateTime.saturday - oggi.weekday) % 7 + 7 * settimane));
  return DateTime(base.year, base.month, base.day, ora);
}

/// Telefono finto, riconoscibile come tale.
String _telefono(int n) => '+39 333 000 ${n.toString().padLeft(4, '0')}';

Future<void> main() async {
  final db = SupabaseAdmin.daAmbiente();
  final password = variabileRichiesta('JAMB_PASSWORD_DEMO');
  final dominio = Platform.environment['JAMB_DOMINIO_DEMO'] ?? 'demo.jamb.test';
  final oggi = DateTime.now();
  final anno = annoScoutDi(oggi);
  final inizioAnno = DateTime(int.parse(anno.split('-').first), 9, 1);

  try {
    // --- Struttura ---
    final gruppoId = await db.trovaOCrea(
      'groups',
      {'nome': _nomeGruppo},
      {'zona': _zona},
    );
    final unita = <String, String>{};
    for (final u in _unita.entries) {
      unita[u.key] = await db.trovaOCrea(
        'units',
        {'group_id': gruppoId, 'tipo_branca': u.key},
        {'nome': u.value},
      );
    }
    final squadre = <String, String>{};
    for (final branca in _squadriglie.entries) {
      for (final s in branca.value.entries) {
        squadre[s.key] = await db.trovaOCrea(
          'squads',
          {'unit_id': unita[branca.key]!, 'nome': s.key},
          {'urlo': s.value.isEmpty ? null : s.value},
        );
      }
    }

    // --- Persone ---
    Future<String> persona(String chiave, String nome, String cognome) =>
        db.creaUtente(
          email: '$chiave@$dominio',
          nome: nome,
          cognome: cognome,
          gruppoId: gruppoId,
          password: password,
        );

    Future<void> membership(
      String utente,
      String branca,
      String ruolo,
      String? squadriglia,
    ) => db.trovaOCrea(
      'memberships',
      {'user_id': utente, 'unit_id': unita[branca]!},
      {
        'ruolo': ruolo,
        'squad_id': squadriglia == null ? null : squadre[squadriglia],
        'anno_scout': anno,
        'data_inizio': _giorno(inizioAnno),
      },
    );

    final capi = <String, String>{};
    for (final c in _capi) {
      capi[c.chiave] = await persona(c.chiave, c.nome, c.cognome);
      await membership(capi[c.chiave]!, c.branca, c.ruolo, null);
    }
    final assistente = await persona(
      _assistente.chiave,
      _assistente.nome,
      _assistente.cognome,
    );
    if (await db.trova('incarichi_trasversali', {'user_id': assistente}) ==
        null) {
      await db.inserisci('incarichi_trasversali', {
        'user_id': assistente,
        'group_id': gruppoId,
        'tipo': 'assistente_ecclesiastico',
        'nominato_da': capi['capogruppo'],
      });
    }

    final ragazzi = <_Ragazzo, String>{};
    for (var i = 0; i < _ragazzi.length; i++) {
      final r = _ragazzi[i];
      final chiave = '${r.nome}.${r.cognome}'
          .toLowerCase()
          .replaceAll(' ', '')
          .replaceAll('ò', 'o');
      ragazzi[r] = await persona(chiave, r.nome, r.cognome);
      await membership(ragazzi[r]!, r.branca, r.ruolo, r.squadriglia);
    }
    stdout.writeln(
      'Struttura e ${capi.length + 1 + ragazzi.length} persone pronte.',
    );

    // --- Contenuti: ogni passo solo se non è già stato fatto, così un
    // lancio interrotto a metà si può ripetere senza doppioni ---
    Future<bool> manca(String tabella, Map<String, String> filtri) async =>
        await db.trova(tabella, filtri) == null;
    final reparto = unita['EG']!;
    final primo = ragazzi.values.first;

    if (await manca('user_dati_sensibili', {'user_id': primo})) {
      await _schede(db, ragazzi, oggi, anno);
    }
    if (await manca('events', {'unit_id': reparto})) {
      await _eventi(db, gruppoId, unita, oggi);
    }
    if (await manca('event_attendances', {'user_id': primo})) {
      final eventi = await db.elenca('events', {'group_id': gruppoId});
      await _appelli(db, _eventiDiUnita(eventi, unita), ragazzi, unita, oggi);
    }
    if (await manca('transactions', {'unit_id': reparto})) {
      await _cassa(db, unita, capi, inizioAnno, oggi);
    }
    final pegObiettivi = await _peg(db, gruppoId);
    if (await manca('obiettivi_educativi', {'unit_id': reparto})) {
      await _programma(db, unita, anno, pegObiettivi);
    }
    if (await manca('notice_board', {'unit_id': reparto})) {
      await _avvisi(db, unita, squadre, capi, oggi);
    }
    if (await manca('campi', {'unit_id': reparto})) {
      await _campo(db, reparto, capi, anno, oggi);
    }
    if (await manca('iter_formativo', {'user_id': capi['capogruppo']!})) {
      await _formazione(db, capi, oggi);
    }
    if (await manca('sottogruppi', {'unit_id': reparto})) {
      await _altaSquadriglia(db, reparto, ragazzi);
    }
    stdout.writeln('Contenuti pronti.');

    stdout.writeln('');
    stdout.writeln(
      'Gruppo dimostrativo "$_nomeGruppo" pronto. Account (password: JAMB_PASSWORD_DEMO):',
    );
    for (final c in _capi) {
      stdout.writeln(
        '  ${c.chiave}@$dominio  ${c.ruolo == 'CAPO_GRUPPO' ? 'Capo Gruppo (vede tutto)' : '${c.ruolo} ${c.branca}'}',
      );
    }
    stdout.writeln(
      '  ${_assistente.chiave}@$dominio  Assistente Ecclesiastico',
    );
  } finally {
    db.chiudi();
  }
}

/// Anagrafica, stati dei documenti, dati sanitari e progressione dei ragazzi.
Future<void> _schede(
  SupabaseAdmin db,
  Map<_Ragazzo, String> ragazzi,
  DateTime oggi,
  String anno,
) async {
  final dati = <Map<String, Object?>>[];
  final tappe = <Map<String, Object?>>[];
  final specialita = <Map<String, Object?>>[];
  var n = 0;
  for (final voce in ragazzi.entries) {
    final r = voce.key;
    final id = voce.value;
    n++;

    // Qualche documento da sistemare, per vedere avvisi e Amministrazione.
    var medica = 'valido';
    var scadenzaMedica = oggi.add(const Duration(days: 180));
    var privacy = 'valido';
    var scadenzaPrivacy = oggi.add(const Duration(days: 240));
    var censimento = 'valido';
    if (n == 3 || n == 19) {
      medica = 'scaduto';
      scadenzaMedica = oggi.subtract(const Duration(days: 12));
    } else if (n == 7 || n == 17) {
      privacy = 'inScadenza';
      scadenzaPrivacy = oggi.add(const Duration(days: 15));
    } else if (n == 11) {
      censimento = 'nessuno';
    }

    await db.aggiorna(
      'users',
      {'id': id},
      {
        'data_nascita': _giorno(
          DateTime(oggi.year - r.eta, 1 + (n * 5) % 12, 1 + (n * 7) % 27),
        ),
        'stato_censimento': censimento,
        'stato_privacy': privacy,
        'stato_medica': medica,
        'scadenza_privacy': _giorno(scadenzaPrivacy),
        'scadenza_medica': _giorno(scadenzaMedica),
        'is_privacy_signed': privacy != 'nessuno',
        'is_medical_delivered': medica == 'valido',
        'medical_alert': r.allergie != null,
      },
    );

    dati.add({
      'user_id': id,
      'allergie': r.allergie,
      'contatti_emergenza': [
        {'nome': 'Mamma', 'telefono': _telefono(n * 2)},
        {'nome': 'Papà', 'telefono': _telefono(n * 2 + 1)},
      ],
    });

    if (r.branca == 'EG') {
      final tipo = r.eta >= 15
          ? 'responsabilita'
          : (r.eta >= 13 ? 'competenza' : 'scoperta');
      tappe.add({
        'user_id': id,
        'tipo': tipo,
        'anno_scout': anno,
        'impegni': [
          {
            'titolo': 'Imparare a montare la tenda di squadriglia da solo',
            'isCompletato': true,
          },
          {
            'titolo': 'Preparare la preghiera per una riunione',
            'isCompletato': n.isEven,
          },
          {
            'titolo': "Curare l'angolo di squadriglia in sede",
            'isCompletato': false,
          },
        ],
      });
    }
  }
  await db.inserisciMolte('user_dati_sensibili', dati);
  await db.inserisciMolte('user_tappe', tappe);

  // Specialità e un brevetto nel Reparto.
  final eg = ragazzi.entries
      .where((e) => e.key.branca == 'EG')
      .map((e) => e.value)
      .toList();
  List<Map<String, Object?>> prove(int fatte) => [
    for (var i = 0; i < 3; i++)
      {
        'titolo': [
          'Prova pratica davanti alla squadriglia',
          'Insegnare a un novizio',
          'Impresa di squadriglia',
        ][i],
        'isCompletato': i < fatte,
      },
  ];
  final conquistata = _giorno(oggi.subtract(const Duration(days: 40)));
  final elenco = [
    [0, 'MaestroDeiNodi', 3],
    [0, 'Campeggiatore', 3],
    [0, 'Boscaiolo', 2],
    [1, 'Infermiere', 3],
    [2, 'Cuoco', 1],
    [5, 'Topografo', 3],
    [5, 'Fotografo', 2],
    [6, 'Segnalatore', 3],
    [10, 'Campeggiatore', 3],
    [11, 'Cantante', 2],
    [12, 'Atleta', 0],
  ];
  for (final s in elenco) {
    final fatte = s[2] as int;
    specialita.add({
      'user_id': eg[s[0] as int],
      'nome': s[1],
      'prove': prove(fatte),
      'data_conseguimento': fatte == 3 ? conquistata : null,
    });
  }
  await db.inserisciMolte('user_specialita', specialita);
  await db.inserisci('user_brevetti', {
    'user_id': eg[0],
    'nome': 'Pioniere',
    'specialita_collegate': ['MaestroDeiNodi', 'Campeggiatore', 'Boscaiolo'],
    'prova_finale_superata': false,
    'prova_finale_descrizione':
        'Progettare e guidare la costruzione della torretta al campo invernale.',
  });
}

/// Riunioni ripetute, uscite, campo, Co.Ca. ed eventi di gruppo.
Future<void> _eventi(
  SupabaseAdmin db,
  String gruppoId,
  Map<String, String> unita,
  DateTime oggi,
) async {
  final righe = <Map<String, Object?>>[];

  void serie(
    String branca,
    String titolo,
    String tipo,
    List<String> categorie,
    String luogo,
    int da,
    int a,
    int giorniDalSabato,
    int ora,
    int durataOre,
  ) {
    final id = _uuid();
    for (var s = da; s <= a; s++) {
      final inizio = _sabato(oggi, s, ora).add(Duration(days: giorniDalSabato));
      righe.add({
        'group_id': gruppoId,
        'unit_id': unita[branca],
        'titolo': titolo,
        'tipo_evento': tipo,
        'categorie_tematiche': categorie,
        'data_inizio': _istante(inizio),
        'data_fine': _istante(inizio.add(Duration(hours: durataOre))),
        'luogo': luogo,
        'tutto_il_giorno': false,
        'serie_id': id,
        'ripetizione': 'settimanale',
      });
    }
  }

  void giornate(
    String? branca,
    String titolo,
    String tipo,
    List<String> categorie,
    String luogo,
    DateTime primo,
    int giorni,
  ) {
    final inizio = DateTime(primo.year, primo.month, primo.day);
    final fine = inizio.add(Duration(days: giorni - 1, hours: 23, minutes: 59));
    righe.add({
      'group_id': gruppoId,
      'unit_id': branca == null ? null : unita[branca],
      'titolo': titolo,
      'tipo_evento': tipo,
      'categorie_tematiche': categorie,
      'data_inizio': _istante(inizio),
      'data_fine': _istante(fine),
      'luogo': luogo,
      'tutto_il_giorno': true,
      // Un inserimento di più righe vuole le stesse colonne in tutte.
      'serie_id': null,
      'ripetizione': null,
    });
  }

  void serata(
    String? branca,
    String titolo,
    String tipo,
    DateTime inizio,
    int ore,
    String luogo,
  ) {
    righe.add({
      'group_id': gruppoId,
      'unit_id': branca == null ? null : unita[branca],
      'titolo': titolo,
      'tipo_evento': tipo,
      'categorie_tematiche': <String>[],
      'data_inizio': _istante(inizio),
      'data_fine': _istante(inizio.add(Duration(hours: ore))),
      'luogo': luogo,
      'tutto_il_giorno': false,
      'serie_id': null,
      'ripetizione': null,
    });
  }

  serie(
    'EG',
    'Riunione di reparto',
    'RIUNIONE',
    ['Comunità e relazioni'],
    'Sede di gruppo',
    -6,
    6,
    0,
    15,
    3,
  );
  serie(
    'LC',
    'Caccia di branco',
    'RIUNIONE',
    ['Gioco e natura'],
    'Sede di gruppo',
    -4,
    6,
    0,
    15,
    2,
  );
  serie(
    'RS',
    'Riunione di clan',
    'RIUNIONE',
    <String>[],
    'Sede di gruppo',
    -4,
    6,
    -1,
    21,
    2,
  );

  giornate(
    'EG',
    'Uscita di reparto ai Piani Alti',
    'USCITA',
    ['Avventura e competenza'],
    'Rifugio dei Piani Alti',
    _sabato(oggi, -3, 0),
    2,
  );
  giornate(
    'EG',
    'Uscita di squadriglia',
    'USCITA',
    ['Avventura e competenza'],
    'Bosco di Montelupo',
    _sabato(oggi, 2, 0),
    2,
  );
  final natale = DateTime(
    oggi.month == 12 && oggi.day > 30 ? oggi.year + 1 : oggi.year,
    12,
    27,
  );
  giornate(
    'EG',
    'Campo invernale',
    'CAMPO',
    ['Avventura e competenza', 'Fede e spiritualità'],
    'Casa scout San Martino',
    natale,
    4,
  );
  giornate(
    'LC',
    'Vacanzina di Natale',
    'USCITA',
    ['Gioco e natura'],
    'Casa del bosco',
    DateTime(natale.year, 12, 28),
    2,
  );
  giornate(
    'RS',
    'Route di servizio',
    'ROUTE',
    <String>[],
    'Mensa solidale di città',
    _sabato(oggi, 4, 0),
    2,
  );

  // Comunità Capi: un mercoledì sì e uno no, la sera.
  for (final s in [-4, -2, 0, 2, 4]) {
    serata(
      'COCA',
      'Riunione di Comunità Capi',
      'RIUNIONE',
      _sabato(oggi, s, 21).subtract(const Duration(days: 3)),
      2,
      'Sede di gruppo',
    );
  }
  serata(
    null,
    'Veglia di Avvento del gruppo',
    'VEGLIA',
    DateTime(natale.year, 12, 19, 20, 30),
    2,
    'Chiesa parrocchiale',
  );
  giornate(
    null,
    'Festa di inizio anno',
    'EVENTO_GRUPPO',
    <String>[],
    'Parco della Rocca',
    DateTime(natale.year, 10, 4),
    1,
  );

  await db.inserisciMolte('events', righe);
}

/// Gli eventi di Branco, Reparto e Clan tra [eventi]: quelli con l'appello.
List<Map<String, dynamic>> _eventiDiUnita(
  List<Map<String, dynamic>> eventi,
  Map<String, String> unita,
) => eventi
    .where((e) => e['unit_id'] != null && e['unit_id'] != unita['COCA'])
    .toList();

/// Appelli delle attività già passate: quasi tutti presenti, qualche
/// giustificato, e un ragazzo con tre assenze di fila (segnalazione).
Future<void> _appelli(
  SupabaseAdmin db,
  List<Map<String, dynamic>> eventi,
  Map<_Ragazzo, String> ragazzi,
  Map<String, String> unita,
  DateTime oggi,
) async {
  final brancaDi = {for (final u in unita.entries) u.value: u.key};
  final passati =
      eventi
          .where(
            (e) => DateTime.parse(e['data_inizio'] as String).isBefore(oggi),
          )
          .toList()
        ..sort(
          (a, b) => (a['data_inizio'] as String).compareTo(
            b['data_inizio'] as String,
          ),
        );
  final assente = ragazzi.entries
      .firstWhere((e) => e.key.nome == 'Francesco')
      .value;
  final righe = <Map<String, Object?>>[];
  for (var i = 0; i < passati.length; i++) {
    final e = passati[i];
    // Posizione dell'evento tra quelli passati della sua unità: 1 = il più recente.
    final dellUnita = passati
        .where((x) => x['unit_id'] == e['unit_id'])
        .toList();
    final posizione = dellUnita.length - dellUnita.indexOf(e);
    var j = 0;
    for (final voce in ragazzi.entries) {
      j++;
      if (brancaDi[e['unit_id']] != voce.key.branca) continue;
      var stato = 'PRESENTE';
      if (voce.value == assente && posizione <= 3) {
        stato = 'ASSENTE';
      } else if ((i + j) % 11 == 0) {
        stato = 'GIUSTIFICATO';
      } else if ((i * 3 + j) % 17 == 0) {
        stato = 'ASSENTE';
      }
      righe.add({
        'event_id': e['id'],
        'user_id': voce.value,
        'stato_presenza': stato,
      });
    }
  }
  await db.inserisciMolte('event_attendances', righe);
}

/// Movimenti di cassa di Reparto, Branco e Clan, anche dell'anno scorso
/// (per avere un saldo iniziale nel bilancio).
Future<void> _cassa(
  SupabaseAdmin db,
  Map<String, String> unita,
  Map<String, String> capi,
  DateTime inizioAnno,
  DateTime oggi,
) async {
  DateTime giorno(int dopoInizio) {
    final d = inizioAnno.add(Duration(days: dopoInizio));
    return d.isAfter(oggi) ? oggi.subtract(const Duration(days: 1)) : d;
  }

  Map<String, Object?> movimento(
    String branca,
    String autore,
    String titolo,
    String tipo,
    double importo,
    String categoria,
    DateTime data, [
    String? note,
  ]) => {
    'unit_id': unita[branca],
    'autore_id': capi[autore],
    'titolo': titolo,
    'tipo': tipo,
    'importo': importo,
    'categoria': categoria,
    'data': _istante(DateTime(data.year, data.month, data.day, 18)),
    'note': note,
  };

  await db.inserisciMolte('transactions', [
    movimento(
      'EG',
      'capo.reparto',
      'Avanzo del campo estivo',
      'ENTRATA',
      380,
      'attivita',
      giorno(-50),
    ),
    movimento(
      'EG',
      'capo.reparto',
      'Rimborso treno di ritorno dal campo',
      'USCITA',
      120,
      'trasporto',
      giorno(-45),
    ),
    movimento(
      'EG',
      'capo.reparto',
      "Quote di inizio anno",
      'ENTRATA',
      675,
      'quote',
      giorno(19),
      '15 ragazzi per 45 euro.',
    ),
    movimento(
      'EG',
      'aiuto.reparto',
      'Corde e materiale da pionieristica',
      'USCITA',
      148.60,
      'materiale',
      giorno(26),
    ),
    movimento(
      'EG',
      'capo.reparto',
      'Castagnata di autofinanziamento',
      'ENTRATA',
      412.50,
      'attivita',
      giorno(40),
    ),
    movimento(
      'EG',
      'aiuto.reparto',
      "Pullman per l'uscita ai Piani Alti",
      'USCITA',
      210,
      'trasporto',
      giorno(55),
    ),
    movimento(
      'EG',
      'capo.reparto',
      'Contributo per il riscaldamento della sede',
      'USCITA',
      80,
      'sede',
      giorno(60),
    ),
    movimento(
      'EG',
      'aiuto.reparto',
      'Cancelleria per le riunioni',
      'USCITA',
      23.90,
      'altro',
      giorno(66),
    ),
    movimento(
      'LC',
      'akela',
      'Quote di inizio anno',
      'ENTRATA',
      405,
      'quote',
      giorno(19),
    ),
    movimento(
      'LC',
      'akela',
      'Materiale per i giochi di caccia',
      'USCITA',
      64.30,
      'materiale',
      giorno(33),
    ),
    movimento(
      'RS',
      'capo.clan',
      'Quote di inizio anno',
      'ENTRATA',
      270,
      'quote',
      giorno(19),
    ),
    movimento(
      'RS',
      'capo.clan',
      'Biglietti per la route di servizio',
      'USCITA',
      96,
      'trasporto',
      giorno(48),
    ),
  ]);
}

/// Progetto Educativo di Gruppo con tre obiettivi; restituisce i loro id,
/// nell'ordine in cui sono scritti qui, anche se esistevano già.
Future<List<String>> _peg(SupabaseAdmin db, String gruppoId) async {
  final esistenti = await db.elenca('peg_obiettivi', {'group_id': gruppoId});
  if (esistenti.isNotEmpty) {
    final perTitolo = {
      for (final o in esistenti) o['titolo']: o['id'] as String,
    };
    return [
      for (final t in const [
        'Vivere la natura con responsabilità',
        'Servire il quartiere',
        'Crescere nella fede insieme',
      ])
        perTitolo[t] ?? esistenti.first['id'] as String,
    ];
  }
  if (await db.trova('peg', {'group_id': gruppoId}) == null) {
    await db.inserisci('peg', {
      'group_id': gruppoId,
      'titolo': 'Radici e ali',
      'premessa':
          'Il nostro gruppo vive in un quartiere che cresce in fretta. In questi tre anni vogliamo '
          'aiutare i ragazzi a mettere radici nella comunità e a prendere il largo con coraggio.',
    });
  }
  final obiettivi = await db.inserisciMolte('peg_obiettivi', [
    {
      'group_id': gruppoId,
      'titolo': 'Vivere la natura con responsabilità',
      'descrizione': 'Più uscite, più competenza, meno sprechi.',
    },
    {
      'group_id': gruppoId,
      'titolo': 'Servire il quartiere',
      'descrizione': 'Ogni unità sceglie un servizio stabile sul territorio.',
    },
    {
      'group_id': gruppoId,
      'titolo': 'Crescere nella fede insieme',
      'descrizione': 'Momenti di spiritualità curati in ogni branca.',
    },
  ]);
  return obiettivi.map((o) => o['id'] as String).toList();
}

/// Programma d'Unità del Reparto e del Branco, collegato al PEG.
Future<void> _programma(
  SupabaseAdmin db,
  Map<String, String> unita,
  String anno,
  List<String> peg,
) async {
  // Codici delle icone di `iconeObiettivo` (lib/domain/entities/obiettivo.dart).
  const chiesa = 983783,
      attrezzi = 63436,
      cammino = 63165,
      fuoco = 63595,
      albero = 983118,
      bussola = 63268;
  Map<String, Object?> obiettivo(
    String branca,
    String dominio,
    String descrizione,
    int grado,
    int colore,
    int icona,
    String diario,
    String? pegId,
  ) => {
    'unit_id': unita[branca],
    'dominio': dominio,
    'descrizione': descrizione,
    'grado': grado,
    'colore': colore,
    'icona': icona,
    'diario_di_bordo': diario,
    'anno_scout': anno,
    'peg_obiettivo_id': pegId,
  };

  await db.inserisciMolte('obiettivi_educativi', [
    obiettivo(
      'EG',
      'Avventura e competenza',
      'Ogni squadriglia sa organizzare da sola una missione di due giorni.',
      3,
      0xFF4A6849,
      bussola,
      "Le Aquile hanno pianificato da sole l'uscita ai Piani Alti.",
      peg[0],
    ),
    obiettivo(
      'EG',
      'Comunità e relazioni',
      'Il Consiglio Capi diventa il luogo dove si decide davvero.',
      4,
      0xFF283664,
      fuoco,
      'Ottima partecipazione ai consigli di novembre.',
      null,
    ),
    obiettivo(
      'EG',
      'Servizio',
      'Un servizio stabile del reparto alla mensa del quartiere.',
      2,
      0xFFE88A42,
      attrezzi,
      'Primo contatto con la mensa, da organizzare i turni.',
      peg[1],
    ),
    obiettivo(
      'EG',
      'Fede e spiritualità',
      'Preghiere e veglie preparate a turno dalle squadriglie.',
      3,
      0xFF8E44AD,
      chiesa,
      '',
      peg[2],
    ),
    obiettivo(
      'LC',
      'Gioco e natura',
      'Ogni caccia ha almeno un momento nel bosco.',
      3,
      0xFF4A6849,
      albero,
      '',
      peg[0],
    ),
    obiettivo(
      'LC',
      'Famiglia felice',
      'Il branco impara a prendersi cura dei più piccoli.',
      2,
      0xFF4A90E2,
      cammino,
      '',
      null,
    ),
  ]);
}

/// Avvisi della bacheca del Reparto, uno solo per una squadriglia.
Future<void> _avvisi(
  SupabaseAdmin db,
  Map<String, String> unita,
  Map<String, String> squadre,
  Map<String, String> capi,
  DateTime oggi,
) async {
  Map<String, Object?> avviso(
    String autore,
    String titolo,
    String testo,
    int giorniFa, [
    String? squadriglia,
  ]) => {
    'unit_id': unita['EG'],
    'squad_id': squadriglia == null ? null : squadre[squadriglia],
    'autore_id': capi[autore],
    'tipo_post': 'AVVISO',
    'titolo': titolo,
    'contenuto': testo,
    'data_pubblicazione': oggi
        .subtract(Duration(days: giorniFa))
        .toUtc()
        .toIso8601String(),
  };
  await db.inserisciMolte('notice_board', [
    avviso(
      'capo.reparto',
      'Campo invernale: iscrizioni aperte',
      'Il campo invernale sarà alla Casa scout San Martino dal 27 al 30 dicembre. Consegnate il modulo firmato entro due settimane.',
      6,
    ),
    avviso(
      'aiuto.reparto',
      'Schede mediche da aggiornare',
      'Alcune schede mediche sono scadute o in scadenza: controllate con i vostri genitori e portatele alla prossima riunione.',
      3,
    ),
    avviso(
      'capo.reparto',
      'Consiglio di squadriglia',
      'Sabato prima della riunione ci vediamo alle 14:30 per preparare la missione di squadriglia.',
      1,
      'Aquile',
    ),
  ]);
}

/// Campo invernale del Reparto: pattuglie di capi con i compiti e i contatti.
Future<void> _campo(
  SupabaseAdmin db,
  String reparto,
  Map<String, String> capi,
  String anno,
  DateTime oggi,
) async {
  final natale = DateTime(
    oggi.month == 12 && oggi.day > 30 ? oggi.year + 1 : oggi.year,
    12,
    27,
  );
  final campo = await db.inserisci('campi', {
    'unit_id': reparto,
    'anno_scout': anno,
    'tipo': 'campo_invernale',
    'titolo': 'Campo invernale',
    'luogo': 'Casa scout San Martino',
    'data_inizio': _giorno(natale),
    'data_fine': _giorno(natale.add(const Duration(days: 3))),
  });
  final pattuglie = await db.inserisciMolte('campo_pattuglie', [
    {'campo_id': campo['id'], 'nome': 'Programma'},
    {'campo_id': campo['id'], 'nome': 'Cucina e cambusa'},
    {'campo_id': campo['id'], 'nome': 'Logistica'},
  ]);
  await db.inserisciMolte('campo_pattuglia_membri', [
    {'pattuglia_id': pattuglie[0]['id'], 'user_id': capi['capo.reparto']},
    {'pattuglia_id': pattuglie[1]['id'], 'user_id': capi['aiuto.reparto']},
    {'pattuglia_id': pattuglie[2]['id'], 'user_id': capi['aiuto.reparto']},
  ]);
  await db.inserisciMolte('campo_compiti', [
    {
      'pattuglia_id': pattuglie[0]['id'],
      'titolo': 'Tema e ambientazione del campo',
      'stato': 'fatto',
    },
    {
      'pattuglia_id': pattuglie[0]['id'],
      'titolo': 'Programma giorno per giorno',
      'stato': 'in_corso',
    },
    {
      'pattuglia_id': pattuglie[0]['id'],
      'titolo': 'Veglia della seconda sera',
      'stato': 'da_fare',
    },
    {
      'pattuglia_id': pattuglie[1]['id'],
      'titolo': 'Menù con i pasti senza glutine',
      'stato': 'in_corso',
    },
    {
      'pattuglia_id': pattuglie[1]['id'],
      'titolo': 'Spesa grossa',
      'stato': 'da_fare',
    },
    {
      'pattuglia_id': pattuglie[2]['id'],
      'titolo': 'Prenotazione della casa',
      'stato': 'fatto',
    },
    {
      'pattuglia_id': pattuglie[2]['id'],
      'titolo': 'Autorizzazioni dei genitori',
      'stato': 'in_corso',
    },
    {
      'pattuglia_id': pattuglie[2]['id'],
      'titolo': 'Trasporto del materiale',
      'stato': 'da_fare',
    },
  ]);
  await db.inserisciMolte('campo_contatti', [
    {
      'campo_id': campo['id'],
      'etichetta': 'Gestore della casa scout',
      'telefono': _telefono(9001),
    },
    {
      'campo_id': campo['id'],
      'etichetta': 'Guardia medica di zona',
      'telefono': _telefono(9002),
    },
  ]);
}

/// Iter formativo dei capi, per il monitoraggio della Co.Ca.
Future<void> _formazione(
  SupabaseAdmin db,
  Map<String, String> capi,
  DateTime oggi,
) async {
  DateTime anniFa(int anni, int mese) => DateTime(oggi.year - anni, mese, 15);
  final tappe = {
    'capogruppo': [
      ('CFT', anniFa(12, 3)),
      ('CFM', anniFa(11, 8)),
      ('CFA', anniFa(9, 4)),
      ('NOMINA', anniFa(8, 11)),
    ],
    'capo.reparto': [
      ('CFT', anniFa(6, 3)),
      ('CFM', anniFa(5, 8)),
      ('CFA', anniFa(3, 4)),
    ],
    'akela': [('CFT', anniFa(4, 3)), ('CFM', anniFa(3, 8))],
    'capo.clan': [('CFT', anniFa(5, 3)), ('CFM', anniFa(4, 7))],
    'aiuto.reparto': [('CFT', anniFa(1, 3))],
  };
  await db.inserisciMolte('iter_formativo', [
    for (final voce in tappe.entries)
      for (final t in voce.value)
        {'user_id': capi[voce.key], 'tappa': t.$1, 'data': _giorno(t.$2)},
  ]);
}

/// Alta Squadriglia del Reparto con i tre capi squadriglia.
Future<void> _altaSquadriglia(
  SupabaseAdmin db,
  String reparto,
  Map<_Ragazzo, String> ragazzi,
) async {
  final alta = await db.inserisci('sottogruppi', {
    'unit_id': reparto,
    'tipo': 'alta_squadriglia',
  });
  await db.inserisciMolte('sottogruppo_membri', [
    for (final voce in ragazzi.entries)
      if (voce.key.branca == 'EG' && voce.key.ruolo == 'CAPO_SQ')
        {'sottogruppo_id': alta['id'], 'user_id': voce.value},
  ]);
}
