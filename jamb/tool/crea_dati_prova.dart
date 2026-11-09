// Crea su un progetto Supabase un gruppo di prova con unità, squadriglie e
// utenti, così da poter provare l'app da zero.
//
// Serve la chiave service_role, che scavalca le RLS: va passata solo
// nell'ambiente, mai scritta in un file. Da jamb/:
//
//   SUPABASE_URL=https://<ref>.supabase.co \
//   SUPABASE_SERVICE_ROLE_KEY=... \
//   JAMB_PASSWORD_PROVA=... \
//   JAMB_CONFERMA_PROGETTO=<ref> \
//   dart run tool/crea_dati_prova.dart
//
// Si può rilanciare: ciò che esiste già viene riusato.
import 'dart:convert';
import 'dart:io';

import 'package:jamb/domain/entities/anno_scout.dart';

const String _nomeGruppo = 'Gruppo di prova';

/// Un utente di prova, con il ruolo nell'unità di branca [branca].
class _UtenteProva {
  final String email;
  final String nome;
  final String cognome;
  final String branca;
  final String ruolo;
  final String? squadriglia;

  const _UtenteProva(this.email, this.nome, this.cognome, this.branca, this.ruolo, [this.squadriglia]);
}

const Map<String, String> _unita = {
  'COCA': 'Comunità Capi di prova',
  'LC': 'Branco di prova',
  'EG': 'Reparto di prova',
  'RS': 'Clan di prova',
};

const List<String> _squadriglie = ['Aquile', 'Volpi'];

const List<_UtenteProva> _utenti = [
  _UtenteProva('prova.capogruppo@test.it', 'Carla', 'Gruppo', 'COCA', 'CAPO_GRUPPO'),
  _UtenteProva('prova.capolc@test.it', 'Luca', 'Branco', 'LC', 'CAPO_UNITA'),
  _UtenteProva('prova.capoeg@test.it', 'Elena', 'Reparto', 'EG', 'CAPO_UNITA'),
  _UtenteProva('prova.aiutoeg@test.it', 'Marco', 'Aiuto', 'EG', 'AIUTO_CAPO'),
  _UtenteProva('prova.capors@test.it', 'Rita', 'Clan', 'RS', 'CAPO_UNITA'),
  _UtenteProva('prova.caposq@test.it', 'Sara', 'Aquile', 'EG', 'CAPO_SQ', 'Aquile'),
  _UtenteProva('prova.ragazzo1@test.it', 'Paolo', 'Aquile', 'EG', 'RAGAZZO', 'Aquile'),
  _UtenteProva('prova.ragazzo2@test.it', 'Giulia', 'Volpi', 'EG', 'RAGAZZO', 'Volpi'),
];

/// Client minimo per PostgREST e Admin API, con la chiave service_role.
class _Supabase {
  final String url;
  final String chiave;
  final HttpClient _http = HttpClient();

  _Supabase(this.url, this.chiave);

  Future<Object?> _invia(String metodo, String percorso, [Object? corpo]) async {
    final richiesta = await _http.openUrl(metodo, Uri.parse('$url$percorso'));
    richiesta.headers
      ..set('apikey', chiave)
      ..set('Authorization', 'Bearer $chiave')
      ..set('Prefer', 'return=representation')
      ..contentType = ContentType.json;
    if (corpo != null) richiesta.add(utf8.encode(jsonEncode(corpo)));

    final risposta = await richiesta.close();
    final testo = await risposta.transform(utf8.decoder).join();
    if (risposta.statusCode >= 300) {
      throw HttpException('$metodo $percorso: ${risposta.statusCode} $testo');
    }
    return testo.isEmpty ? null : jsonDecode(testo);
  }

  /// Prima riga di [tabella] che rispetta [filtri], o `null`.
  Future<Map<String, dynamic>?> trova(String tabella, Map<String, String> filtri) async {
    final query = filtri.entries
        .map((f) => '${f.key}=eq.${Uri.encodeQueryComponent(f.value)}')
        .join('&');
    final righe = await _invia('GET', '/rest/v1/$tabella?$query&limit=1') as List;
    return righe.isEmpty ? null : righe.first as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> inserisci(String tabella, Map<String, Object?> riga) async {
    final righe = await _invia('POST', '/rest/v1/$tabella', riga) as List;
    return righe.first as Map<String, dynamic>;
  }

  /// La riga che rispetta [filtri], creandola con anche [altri] se manca.
  Future<String> trovaOCrea(
    String tabella,
    Map<String, String> filtri, [
    Map<String, Object?> altri = const {},
  ]) async {
    final esistente = await trova(tabella, filtri);
    final riga = esistente ?? await inserisci(tabella, {...filtri, ...altri});
    return riga['id'] as String;
  }

  /// Id dell'utente di Auth con [email], o `null`.
  Future<String?> _idUtente(String email) async {
    for (var pagina = 1;; pagina++) {
      final risposta = await _invia('GET', '/auth/v1/admin/users?page=$pagina&per_page=200') as Map;
      final utenti = risposta['users'] as List;
      if (utenti.isEmpty) return null;
      for (final u in utenti) {
        if (u['email'] == email) return u['id'] as String;
      }
    }
  }

  /// Crea l'utente con l'Admin API: il trigger `handle_new_user` scrive la
  /// riga in `users` leggendo i metadati. Mai `INSERT` in `auth.users`.
  Future<String> creaUtente(_UtenteProva u, String gruppoId, String password) async {
    final esistente = await _idUtente(u.email);
    if (esistente != null) return esistente;
    final creato = await _invia('POST', '/auth/v1/admin/users', {
      'email': u.email,
      'password': password,
      'email_confirm': true,
      'user_metadata': {'group_id': gruppoId, 'nome': u.nome, 'cognome': u.cognome},
    }) as Map;
    return creato['id'] as String;
  }

  void chiudi() => _http.close();
}

String _richiesta(String nome) {
  final valore = Platform.environment[nome];
  if (valore == null || valore.isEmpty) {
    stderr.writeln('Manca la variabile di ambiente $nome.');
    exit(64);
  }
  return valore;
}

Future<void> main() async {
  final url = _richiesta('SUPABASE_URL');
  final chiave = _richiesta('SUPABASE_SERVICE_ROLE_KEY');
  final password = _richiesta('JAMB_PASSWORD_PROVA');

  // La chiave scavalca le RLS: si scrive solo sul progetto indicato di proposito.
  final progetto = Uri.parse(url).host.split('.').first;
  if (_richiesta('JAMB_CONFERMA_PROGETTO') != progetto) {
    stderr.writeln('JAMB_CONFERMA_PROGETTO non coincide con il progetto $progetto.');
    exit(64);
  }

  final db = _Supabase(url, chiave);
  try {
    final oggi = DateTime.now();
    final gruppoId = await db.trovaOCrea('groups', {'nome': _nomeGruppo}, {'zona': 'Prova'});

    final unitaIds = <String, String>{};
    for (final voce in _unita.entries) {
      unitaIds[voce.key] = await db.trovaOCrea(
        'units',
        {'group_id': gruppoId, 'tipo_branca': voce.key},
        {'nome': voce.value},
      );
    }

    final squadriglieIds = <String, String>{};
    for (final nome in _squadriglie) {
      squadriglieIds[nome] = await db.trovaOCrea('squads', {'unit_id': unitaIds['EG']!, 'nome': nome});
    }

    for (final u in _utenti) {
      final utenteId = await db.creaUtente(u, gruppoId, password);
      await db.trovaOCrea(
        'memberships',
        {'user_id': utenteId, 'unit_id': unitaIds[u.branca]!},
        {
          'ruolo': u.ruolo,
          'squad_id': u.squadriglia == null ? null : squadriglieIds[u.squadriglia],
          'anno_scout': annoScoutDi(oggi),
          'data_inizio': oggi.toIso8601String().split('T').first,
        },
      );
      stdout.writeln('${u.email}: ${u.ruolo} in ${u.branca}');
    }
    stdout.writeln('Dati di prova pronti nel gruppo "$_nomeGruppo".');
  } finally {
    db.chiudi();
  }
}
