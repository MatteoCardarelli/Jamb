import 'package:jamb/core/permessi.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/cache_letture.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/data/nome_completo.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/formazione.dart';
import '../../domain/repositories/formazione_repository.dart';

/// Iter formativo e Progetto del Capo su Supabase. Ogni capo scrive i propri
/// dati; il Capo Gruppo li legge tramite le RLS.
class SupabaseFormazioneRepository extends IFormazioneRepository {
  final SessionService _session;
  final CacheLetture _cache;
  SupabaseFormazioneRepository(this._session, this._cache);

  String get _utente {
    final id = _session.userId;
    if (id == null) throw sessioneSenzaUtente;
    return id;
  }

  /// Ricostruisce una tappa; `null` se il valore non è noto all'app.
  TappaCompiuta? _tappaDaDb(Map<String, dynamic> r) {
    final tappa = TappaFormativa.daDb(r['tappa']);
    if (tappa == null) return null;
    return TappaCompiuta(
      tappa: tappa,
      data: DateTime.parse(r['data'] as String),
      note: (r['note'] ?? '') as String,
    );
  }

  ProgettoCapo _progettoDaDb(Map<String, dynamic>? r) {
    if (r == null) return const ProgettoCapo();
    final passi = r['passi'];
    return ProgettoCapo(
      testo: (r['testo'] ?? '') as String,
      passi: [
        if (passi is List)
          for (final p in passi.whereType<Map>())
            PassoProgetto(titolo: (p['titolo'] ?? '') as String, fatto: p['fatto'] == true),
      ],
    );
  }

  @override
  Future<List<TappaCompiuta>> getMieTappe() => _cache.leggiSupabase('formazione/tappe', () async {
        final List<dynamic> righe =
            await supabase.from('iter_formativo').select().eq('user_id', _utente);
        return righe.cast<Map<String, dynamic>>().map(_tappaDaDb).whereType<TappaCompiuta>().toList();
      });

  @override
  Future<void> salvaTappa(TappaCompiuta t) => eseguiSupabase(() async {
        await supabase.from('iter_formativo').upsert({
          'user_id': _utente,
          'tappa': t.tappa.valoreDb,
          'data': t.data.toIso8601String().split('T').first,
          'note': t.note,
        });
        _cache.dimentica(const ['formazione/tappe', 'formazione/capi']);
        notifyListeners();
      });

  @override
  Future<void> rimuoviTappa(TappaFormativa tappa) => eseguiSupabase(() async {
        await supabase
            .from('iter_formativo')
            .delete()
            .eq('user_id', _utente)
            .eq('tappa', tappa.valoreDb);
        _cache.dimentica(const ['formazione/tappe', 'formazione/capi']);
        notifyListeners();
      });

  @override
  Future<ProgettoCapo> getMioProgetto() => getProgettoDi(_utente);

  @override
  Future<void> salvaMioProgetto(ProgettoCapo p) => eseguiSupabase(() async {
        await supabase.from('progetti_capo').upsert({
          'user_id': _utente,
          'testo': p.testo,
          'passi': [
            for (final passo in p.passi) {'titolo': passo.titolo, 'fatto': passo.fatto},
          ],
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        _cache.dimentica(const ['formazione/progetto']);
        notifyListeners();
      });

  @override
  Future<ProgettoCapo> getProgettoDi(String userId) => _cache.leggiSupabase('formazione/progetto/$userId', () async {
        final riga =
            await supabase.from('progetti_capo').select().eq('user_id', userId).maybeSingle();
        return _progettoDaDb(riga);
      });

  @override
  Future<List<IncaricoStorico>> getMioStorico() => _cache.leggiSupabase('formazione/storico', () async {
        final List<dynamic> righe = await supabase
            .from('memberships')
            .select('ruolo, anno_scout, units ( tipo_branca )')
            .eq('user_id', _utente);
        return [
          for (final r in righe)
            IncaricoStorico(
              ruolo: (r['ruolo'] ?? '') as String,
              annoScout: (r['anno_scout'] ?? '') as String,
              tipoBranca: (r['units'] as Map?)?['tipo_branca'] as String?,
            ),
        ];
      });

  @override
  Future<List<CapoFormazione>> getCapiDelGruppo() => _cache.leggiSupabase('formazione/capi', () async {
        final groupId = _session.groupId;
        if (groupId == null) return [];
        final List<dynamic> righe = await supabase
            .from('memberships')
            .select('user_id, ruolo, users ( nome, cognome ), units!inner ( group_id )')
            .eq('units.group_id', groupId)
            .eq('is_active', true)
            .inFilter('ruolo', const ['AIUTO_CAPO', 'CAPO_UNITA', 'CAPO_GRUPPO']);

        // Chi serve in più unità compare una volta, con il ruolo più alto.
        final perUtente = <String, Map<String, dynamic>>{};
        for (final r in righe.cast<Map<String, dynamic>>()) {
          final id = r['user_id'] as String;
          final attuale = perUtente[id];
          if (attuale == null ||
              gerarchiaRuoli.indexOf(r['ruolo'] as String) >
                  gerarchiaRuoli.indexOf(attuale['ruolo'] as String)) {
            perUtente[id] = r;
          }
        }
        if (perUtente.isEmpty) return [];

        final List<dynamic> iter = await supabase
            .from('iter_formativo')
            .select()
            .inFilter('user_id', perUtente.keys.toList());
        final tappe = <String, List<TappaCompiuta>>{};
        for (final r in iter.cast<Map<String, dynamic>>()) {
          final t = _tappaDaDb(r);
          if (t != null) tappe.putIfAbsent(r['user_id'] as String, () => []).add(t);
        }

        return [
          for (final e in perUtente.entries)
            CapoFormazione(
              id: e.key,
              nome: nomeCompletoDa(e.value['users']),
              ruolo: e.value['ruolo'] as String,
              tappe: tappe[e.key] ?? const [],
            ),
        ];
      });

}
