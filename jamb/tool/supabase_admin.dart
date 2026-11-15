// Client minimo per PostgREST e Admin API di Supabase, condiviso dagli
// script che preparano dati (prova, gruppo dimostrativo).
//
// Usa la chiave service_role, che scavalca le RLS: si legge solo
// dall'ambiente e lo script parte solo se JAMB_CONFERMA_PROGETTO ripete il
// riferimento del progetto.
import 'dart:convert';
import 'dart:io';

/// Valore della variabile d'ambiente [nome]; esce con un messaggio se manca.
String variabileRichiesta(String nome) {
  final valore = Platform.environment[nome];
  if (valore == null || valore.isEmpty) {
    stderr.writeln('Manca la variabile di ambiente $nome.');
    exit(64);
  }
  return valore;
}

/// Client con la chiave service_role, creato dalle variabili d'ambiente.
class SupabaseAdmin {
  final String url;
  final String _chiave;
  final HttpClient _http = HttpClient();

  SupabaseAdmin._(this.url, this._chiave);

  /// Legge `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` e controlla che
  /// `JAMB_CONFERMA_PROGETTO` coincida con il progetto: la chiave scavalca le
  /// RLS, quindi si scrive solo sul progetto indicato di proposito.
  factory SupabaseAdmin.daAmbiente() {
    final url = variabileRichiesta('SUPABASE_URL');
    final chiave = variabileRichiesta('SUPABASE_SERVICE_ROLE_KEY');
    final progetto = Uri.parse(url).host.split('.').first;
    if (variabileRichiesta('JAMB_CONFERMA_PROGETTO') != progetto) {
      stderr.writeln(
        'JAMB_CONFERMA_PROGETTO non coincide con il progetto $progetto.',
      );
      exit(64);
    }
    return SupabaseAdmin._(url, chiave);
  }

  Future<Object?> _invia(
    String metodo,
    String percorso, [
    Object? corpo,
  ]) async {
    final richiesta = await _http.openUrl(metodo, Uri.parse('$url$percorso'));
    richiesta.headers
      ..set('apikey', _chiave)
      ..set('Authorization', 'Bearer $_chiave')
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

  static String _filtri(Map<String, String> filtri) => filtri.entries
      .map((f) => '${f.key}=eq.${Uri.encodeQueryComponent(f.value)}')
      .join('&');

  /// Prima riga di [tabella] che rispetta [filtri], o `null`.
  Future<Map<String, dynamic>?> trova(
    String tabella,
    Map<String, String> filtri,
  ) async {
    final righe =
        await _invia('GET', '/rest/v1/$tabella?${_filtri(filtri)}&limit=1')
            as List;
    return righe.isEmpty ? null : righe.first as Map<String, dynamic>;
  }

  /// Inserisce una riga e la restituisce come salvata.
  Future<Map<String, dynamic>> inserisci(
    String tabella,
    Map<String, Object?> riga,
  ) async {
    final righe = await _invia('POST', '/rest/v1/$tabella', riga) as List;
    return righe.first as Map<String, dynamic>;
  }

  /// Inserisce più righe in una sola richiesta (tutte o nessuna) e le
  /// restituisce nello stesso ordine.
  Future<List<Map<String, dynamic>>> inserisciMolte(
    String tabella,
    List<Map<String, Object?>> righe,
  ) async {
    if (righe.isEmpty) return const [];
    final salvate = await _invia('POST', '/rest/v1/$tabella', righe) as List;
    return salvate.cast<Map<String, dynamic>>();
  }

  /// L'id della riga che rispetta [filtri], creandola con anche [altri] se manca.
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
    for (var pagina = 1; ; pagina++) {
      final risposta =
          await _invia('GET', '/auth/v1/admin/users?page=$pagina&per_page=200')
              as Map;
      final utenti = risposta['users'] as List;
      if (utenti.isEmpty) return null;
      for (final u in utenti) {
        if (u['email'] == email) return u['id'] as String;
      }
    }
  }

  /// Crea l'utente con l'Admin API, se non esiste già: il trigger
  /// `handle_new_user` scrive la riga in `users` leggendo i metadati.
  /// Mai `INSERT` in `auth.users`.
  Future<String> creaUtente({
    required String email,
    required String nome,
    required String cognome,
    required String gruppoId,
    required String password,
  }) async {
    final esistente = await _idUtente(email);
    if (esistente != null) return esistente;
    final creato =
        await _invia('POST', '/auth/v1/admin/users', {
              'email': email,
              'password': password,
              'email_confirm': true,
              'user_metadata': {
                'group_id': gruppoId,
                'nome': nome,
                'cognome': cognome,
              },
            })
            as Map;
    return creato['id'] as String;
  }

  /// Aggiorna le righe di [tabella] che rispettano [filtri].
  Future<void> aggiorna(
    String tabella,
    Map<String, String> filtri,
    Map<String, Object?> valori,
  ) => _invia('PATCH', '/rest/v1/$tabella?${_filtri(filtri)}', valori);

  void chiudi() => _http.close();
}
