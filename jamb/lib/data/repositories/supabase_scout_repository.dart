import 'package:flutter/foundation.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/core/session_service.dart';
import '../../domain/entities/scout.dart';
import '../../domain/entities/progresso.dart';
import '../../domain/repositories/scout_repository.dart';

/// Repository degli scout su Supabase.
///
/// Uno [Scout] è un aggregato ricomposto da più tabelle (`users`,
/// `memberships`, `squads`, `user_dati_sensibili`, `user_tappe`,
/// `user_specialita`, `user_brevetti`). La lettura usa una singola query con
/// join annidati; la scrittura aggiorna ogni tabella coinvolta.
class SupabaseScoutRepository extends IScoutRepository {
  final SessionService _session;
  SupabaseScoutRepository(this._session);

  @override
  Future<List<Scout>> getRagazzi() async {
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

  @override
  Future<List<String>> getSquadriglie() async {
    final unitId = _session.activeUnitId;
    if (unitId == null) return [];
    final List<dynamic> rows = await supabase
        .from('squads')
        .select('nome')
        .eq('unit_id', unitId)
        .eq('is_active', true)
        .order('nome');
    return rows.map((r) => r['nome'] as String).toList();
  }

  @override
  Future<void> salvaRagazzo(Scout ragazzo) async {
    final userId = ragazzo.id;

    // 0. Membership (SCD Type 2): se ruolo o squadriglia sono cambiati,
    //    chiude la membership attiva e ne apre una nuova.
    const ruoliValidi = {
      'RAGAZZO', 'VICE_CAPO_SQ', 'CAPO_SQ',
      'AIUTO_CAPO', 'CAPO_UNITA', 'CAPO_GRUPPO'
    };
    final unitIdMembership = _session.activeUnitId;
    if (unitIdMembership != null) {
      final current = await supabase
          .from('memberships')
          .select('id, ruolo, squad_id, anno_scout')
          .eq('user_id', userId)
          .eq('unit_id', unitIdMembership)
          .eq('is_active', true)
          .maybeSingle();

      if (current != null) {
        final nuovoSquadId =
            await _squadIdDaNome(ragazzo.squadriglia, unitIdMembership);
        final ruoloCambiato = ruoliValidi.contains(ragazzo.ruolo) &&
            current['ruolo'] != ragazzo.ruolo;
        final squadCambiata =
            nuovoSquadId != null && current['squad_id'] != nuovoSquadId;

        if (ruoloCambiato || squadCambiata) {
          final oggi = DateTime.now().toIso8601String().split('T').first;
          await supabase.from('memberships').update({
            'is_active': false,
            'data_fine': oggi,
          }).eq('id', current['id']);
          await supabase.from('memberships').insert({
            'user_id': userId,
            'unit_id': unitIdMembership,
            'squad_id': nuovoSquadId ?? current['squad_id'],
            'ruolo': ruoloCambiato ? ragazzo.ruolo : current['ruolo'],
            'is_active': true,
            'anno_scout': current['anno_scout'] ?? _annoScoutCorrente(),
            'data_inizio': oggi,
          });
        }
      }
    }

    // 1. Tappa (strategia replace: cancella e reinserisce quella attuale).
    await supabase.from('user_tappe').delete().eq('user_id', userId);
    final tappa = ragazzo.progresso.tappaAttuale;
    if (tappa.tipo != TappaSentiero.nulla || tappa.impegni.isNotEmpty) {
      await supabase.from('user_tappe').insert({
        'user_id': userId,
        'tipo': tappa.tipo.name,
        'impegni': tappa.impegni
            .map((i) => {'titolo': i.titolo, 'isCompletato': i.isCompletato})
            .toList(),
        'anno_scout': _annoScoutCorrente(),
      });
    }

    // 2. Specialità (replace).
    await supabase.from('user_specialita').delete().eq('user_id', userId);
    if (ragazzo.progresso.specialita.isNotEmpty) {
      await supabase.from('user_specialita').insert(
        ragazzo.progresso.specialita
            .map((s) => {
                  'user_id': userId,
                  'nome': s.nome.name,
                  'prove': s.prove
                      .map((i) =>
                          {'titolo': i.titolo, 'isCompletato': i.isCompletato})
                      .toList(),
                  'data_conseguimento': _dateOnly(s.dataConseguimento),
                })
            .toList(),
      );
    }

    // 3. Brevetti (replace).
    await supabase.from('user_brevetti').delete().eq('user_id', userId);
    if (ragazzo.progresso.brevetti.isNotEmpty) {
      await supabase.from('user_brevetti').insert(
        ragazzo.progresso.brevetti
            .map((b) => {
                  'user_id': userId,
                  'nome': b.nome.name,
                  'specialita_collegate':
                      b.specialitaCollegate.map((e) => e.name).toList(),
                  'prova_finale_superata': b.provaFinaleSuperata,
                  'prova_finale_descrizione': b.provaFinaleDescrizione,
                  'data_conseguimento': _dateOnly(b.dataConseguimento),
                })
            .toList(),
      );
    }

    // 4. Dati sensibili (upsert, non delete: preserva `note_mediche` che
    //    l'entità Scout non modella e non deve sovrascrivere).
    await supabase.from('user_dati_sensibili').upsert({
      'user_id': userId,
      'allergie': ragazzo.allergie,
      'contatti_emergenza': ragazzo.contattiEmergenza
          .map((c) => {'nome': c.nome, 'telefono': c.telefono})
          .toList(),
    }, onConflict: 'user_id');

    // 5. Stati amministrativi su `users`: censimento / privacy / medica + scadenze.
    await supabase.from('users').update({
      'stato_censimento': ragazzo.statoCensimento.name,
      'stato_privacy': ragazzo.statoPrivacy.name,
      'stato_medica': ragazzo.statoMedica.name,
      'scadenza_privacy': _dateOnly(ragazzo.scadenzaPrivacy),
      'scadenza_medica': _dateOnly(ragazzo.scadenzaMedica),
    }).eq('id', userId);

    notifyListeners();
  }

  /// Anno scout corrente in formato "AAAA-AAAA" (l'annata va da settembre ad agosto).
  String _annoScoutCorrente() {
    final now = DateTime.now();
    final inizio = now.month >= 9 ? now.year : now.year - 1;
    return '$inizio-${inizio + 1}';
  }

  /// Risolve il nome di una squadriglia nel relativo `squad_id` dell'unità
  /// (null se il nome è vuoto o non trovato).
  Future<String?> _squadIdDaNome(String nome, String unitId) async {
    if (nome.trim().isEmpty) return null;
    final row = await supabase
        .from('squads')
        .select('id')
        .eq('unit_id', unitId)
        .eq('nome', nome)
        .maybeSingle();
    return row?['id'] as String?;
  }

  /// Formatta una data come 'AAAA-MM-GG' per le colonne di tipo `date`.
  String? _dateOnly(DateTime? d) =>
      d == null ? null : d.toIso8601String().split('T').first;

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
