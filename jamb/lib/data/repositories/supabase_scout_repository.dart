import 'package:flutter/foundation.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/scout.dart';
import '../../domain/entities/progresso.dart';
import '../../domain/repositories/scout_repository.dart';

/// Repository degli scout su Supabase.
///
/// Uno [Scout] è un aggregato ricomposto da più tabelle (`users`,
/// `memberships`, `squads`, `user_dati_sensibili`, `user_tappe`,
/// `user_specialita`, `user_brevetti`). La lettura usa una singola query con
/// join annidati; la scrittura passa dalla funzione SQL transazionale
/// `salva_ragazzo`.
class SupabaseScoutRepository extends IScoutRepository {
  final SessionService _session;
  SupabaseScoutRepository(this._session);

  @override
  Future<List<Scout>> getRagazzi() => eseguiSupabase(_leggiRagazzi);

  @override
  Future<List<String>> getSquadriglie() => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final List<dynamic> rows = await supabase
            .from('squads')
            .select('nome')
            .eq('unit_id', unitId)
            .eq('is_active', true)
            .order('nome');
        return rows.map((r) => r['nome'] as String).toList();
      });

  @override
  Future<void> salvaRagazzo(Scout ragazzo) =>
      eseguiSupabase(() => _scriviRagazzo(ragazzo));

  Future<List<Scout>> _leggiRagazzi() async {
    final unitId = _session.activeUnitId;
    if (unitId == null) return []; // nessuna unità attiva → nessun ragazzo

    final List<dynamic> rows = await supabase.from('users').select('''
          id, nome, cognome,
          stato_censimento, stato_privacy, stato_medica,
          scadenza_privacy, scadenza_medica,
          memberships!inner ( ruolo, is_active, unit_id, squads ( nome ) ),
          user_dati_sensibili ( allergie, contatti_emergenza ),
          user_tappe ( tipo, impegni, updated_at ),
          user_specialita ( nome, prove, data_conseguimento ),
          user_brevetti ( nome, specialita_collegate, prova_finale_superata,
                          prova_finale_descrizione, data_conseguimento )
        ''')
        .eq('memberships.unit_id', unitId)
        .eq('memberships.is_active', true)
        .inFilter('memberships.ruolo', ['RAGAZZO', 'VICE_CAPO_SQ', 'CAPO_SQ'])
        .order('cognome', ascending: true)
        .order('nome', ascending: true);

    final scouts = <Scout>[];
    for (final row in rows) {
      final scout = _mapScout(row as Map<String, dynamic>);
      if (scout != null) scouts.add(scout);
    }
    return scouts;
  }

  /// Salva l'aggregato con la funzione SQL `salva_ragazzo`, che aggiorna
  /// membership, progressione, dati sensibili e stati amministrativi in
  /// un'unica transazione: o riescono tutte le scritture o nessuna.
  Future<void> _scriviRagazzo(Scout ragazzo) async {
    await supabase.rpc('salva_ragazzo', params: {
      'p_unit_id': _session.activeUnitId,
      'p_ragazzo': payloadRagazzo(ragazzo),
    });
    notifyListeners();
  }

  /// Rappresentazione JSON dello [Scout] letta dalla funzione `salva_ragazzo`
  /// (la forma è documentata nella migrazione che la definisce).
  @visibleForTesting
  static Map<String, dynamic> payloadRagazzo(Scout ragazzo) {
    List<Map<String, dynamic>> impegni(List<Impegno> lista) => lista
        .map((i) => {'titolo': i.titolo, 'isCompletato': i.isCompletato})
        .toList();

    final tappa = ragazzo.progresso.tappaAttuale;
    return {
      'id': ragazzo.id,
      'ruolo': ragazzo.ruolo,
      'squadriglia': ragazzo.squadriglia,
      'tappa': {'tipo': tappa.tipo.name, 'impegni': impegni(tappa.impegni)},
      'specialita': ragazzo.progresso.specialita
          .map((s) => {
                'nome': s.nome.name,
                'prove': impegni(s.prove),
                'data_conseguimento': _dateOnly(s.dataConseguimento),
              })
          .toList(),
      'brevetti': ragazzo.progresso.brevetti
          .map((b) => {
                'nome': b.nome.name,
                'specialita_collegate':
                    b.specialitaCollegate.map((e) => e.name).toList(),
                'prova_finale_superata': b.provaFinaleSuperata,
                'prova_finale_descrizione': b.provaFinaleDescrizione,
                'data_conseguimento': _dateOnly(b.dataConseguimento),
              })
          .toList(),
      'allergie': ragazzo.allergie,
      'contatti_emergenza': ragazzo.contattiEmergenza
          .map((c) => {'nome': c.nome, 'telefono': c.telefono})
          .toList(),
      'stato_censimento': ragazzo.statoCensimento.name,
      'stato_privacy': ragazzo.statoPrivacy.name,
      'stato_medica': ragazzo.statoMedica.name,
      'scadenza_privacy': _dateOnly(ragazzo.scadenzaPrivacy),
      'scadenza_medica': _dateOnly(ragazzo.scadenzaMedica),
    };
  }

  /// Formatta una data come 'AAAA-MM-GG' per le colonne di tipo `date`.
  static String? _dateOnly(DateTime? d) =>
      d?.toIso8601String().split('T').first;

  // ---- mapping DB -> entità ----

  /// Ricompone uno [Scout] da una riga con join annidati; restituisce `null`
  /// se il mapping fallisce (record malformato).
  Scout? _mapScout(Map<String, dynamic> row) {
    try {
      final membership = _firstMap(row['memberships']);
      final dati = _firstMap(row['user_dati_sensibili']);
      final squad = membership != null ? _firstMap(membership['squads']) : null;

      final nome = [row['nome'], row['cognome']]
          .where((e) => e != null && (e as String).trim().isNotEmpty)
          .join(' ');

      return Scout(
        id: row['id'] as String,
        nome: nome.isEmpty ? 'Senza nome' : nome,
        squadriglia: (squad?['nome'] ?? '') as String,
        ruolo: (membership?['ruolo'] ?? '') as String,
        allergie: dati?['allergie'] as String?,
        statoCensimento:
            DocumentoStatus.safeByName((row['stato_censimento'] ?? '') as String),
        statoPrivacy:
            DocumentoStatus.safeByName((row['stato_privacy'] ?? '') as String),
        statoMedica:
            DocumentoStatus.safeByName((row['stato_medica'] ?? '') as String),
        scadenzaPrivacy: _parseDate(row['scadenza_privacy']),
        scadenzaMedica: _parseDate(row['scadenza_medica']),
        contattiEmergenza: _mapContatti(dati?['contatti_emergenza']),
        progresso: _mapProgresso(row),
      );
    } catch (e) {
      debugPrint('Errore mapping scout ${row['id']}: $e');
      return null;
    }
  }

  /// Ricompone la progressione (tappa attuale, specialità, brevetti) dalla riga.
  ProgressoScout _mapProgresso(Map<String, dynamic> row) {
    // La tappa attuale è la riga di user_tappe più recente.
    final tappe = _asList(row['user_tappe']);
    Tappa tappaAttuale = const Tappa(tipo: TappaSentiero.nulla, impegni: []);
    if (tappe.isNotEmpty) {
      tappe.sort((a, b) => (_parseDate(b['updated_at']) ?? DateTime(0))
          .compareTo(_parseDate(a['updated_at']) ?? DateTime(0)));
      final t = tappe.first as Map<String, dynamic>;
      tappaAttuale = Tappa(
        tipo: TappaSentiero.safeByName((t['tipo'] ?? '') as String),
        impegni: _mapImpegni(t['impegni']),
      );
    }

    final specialita = _asList(row['user_specialita'])
        .map((s) => Specialita.fromMap({
              'nome': s['nome'],
              'prove': s['prove'],
              'dataConseguimento': s['data_conseguimento'],
            }))
        .whereType<Specialita>()
        .toList();

    final brevetti = _asList(row['user_brevetti'])
        .map((b) => Brevetto.fromMap({
              'nome': b['nome'],
              'specialitaCollegate': b['specialita_collegate'] ?? const [],
              'provaFinaleSuperata': b['prova_finale_superata'] ?? false,
              'provaFinaleDescrizione': b['prova_finale_descrizione'],
              'dataConseguimento': b['data_conseguimento'],
            }))
        .whereType<Brevetto>()
        .toList();

    return ProgressoScout(
      tappaAttuale: tappaAttuale,
      specialita: specialita,
      brevetti: brevetti,
    );
  }

  /// Converte la lista JSONB degli impegni in oggetti [Impegno].
  List<Impegno> _mapImpegni(dynamic raw) => _asList(raw)
      .map((e) => Impegno.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();

  /// Converte la lista JSONB dei contatti in oggetti [ContattoEmergenza].
  List<ContattoEmergenza> _mapContatti(dynamic raw) => _asList(raw)
      .map((e) => ContattoEmergenza.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();

  // ---- helpers ----

  /// Normalizza una relazione PostgREST: le to-one arrivano come oggetto e le
  /// to-many come lista; qui vengono ricondotte entrambe a una lista.
  List<dynamic> _asList(dynamic v) {
    if (v is List) return v;
    if (v is Map) return [v];
    return const [];
  }

  /// Estrae la prima mappa da un valore che può essere oggetto o lista.
  Map<String, dynamic>? _firstMap(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    if (v is List && v.isNotEmpty && v.first is Map) {
      return Map<String, dynamic>.from(v.first as Map);
    }
    return null;
  }

  /// Converte una stringa data del DB in [DateTime] (null se assente/non valida).
  DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
