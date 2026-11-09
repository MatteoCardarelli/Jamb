import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/cache_letture.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/data/nome_completo.dart';
import '../../domain/entities/sottogruppi.dart';
import '../../domain/repositories/sottogruppo_repository.dart';

/// Squadriglie (`squads`) e sottogruppi (`sottogruppi`, `sottogruppo_membri`)
/// dell'unità attiva, presa dalla sessione; le RLS decidono chi modifica.
class SupabaseSottogruppoRepository extends ISottogruppoRepository {
  final SessionService _session;
  final CacheLetture _cache;
  SupabaseSottogruppoRepository(this._session, this._cache);

  @override
  Future<List<Squadriglia>> getSquadriglie() => _cache.leggiSupabase('sottogruppi/squadriglie', () async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final List<dynamic> righe =
            await supabase.from('squads').select().eq('unit_id', unitId).order('nome');
        return [
          for (final r in righe)
            Squadriglia(
              id: r['id'] as String,
              nome: (r['nome'] ?? '') as String,
              urlo: (r['urlo'] ?? '') as String,
              attiva: r['is_active'] != false,
            ),
        ];
      });

  @override
  Future<List<MembroUnita>> getMembriUnita() => _cache.leggiSupabase('sottogruppi/membri', () async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final List<dynamic> righe = await supabase
            .from('memberships')
            .select('user_id, ruolo, users ( nome, cognome ), squads ( nome )')
            .eq('unit_id', unitId)
            .eq('is_active', true);
        final membri = [
          for (final r in righe)
            MembroUnita(
              id: r['user_id'] as String,
              nome: nomeCompletoDa(r['users']),
              ruolo: (r['ruolo'] ?? '') as String,
              squadriglia: (r['squads'] as Map?)?['nome'] as String?,
            ),
        ];
        return membri..sort((a, b) => a.nome.compareTo(b.nome));
      });


  @override
  Future<List<Sottogruppo>> getSottogruppi() => _cache.leggiSupabase('sottogruppi/scelti', () async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final List<dynamic> righe = await supabase
            .from('sottogruppi')
            .select('tipo, sottogruppo_membri ( user_id )')
            .eq('unit_id', unitId);
        return [
          for (final r in righe)
            // Un tipo che l'app non conosce si ignora.
            if (TipoSottogruppo.daDb(r['tipo']) case final tipo?)
              Sottogruppo(
                tipo: tipo,
                membri: {
                  for (final m in (r['sottogruppo_membri'] as List? ?? const []))
                    m['user_id'] as String,
                },
              ),
        ];
      });

  @override
  Future<void> creaSquadriglia(String nome) => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) throw sessioneSenzaUnita;
        await supabase.from('squads').insert({'unit_id': unitId, 'nome': nome.trim()});
        _cache.dimentica(const ['sottogruppi', 'ragazzi', 'squadriglie']);
        notifyListeners();
      });

  @override
  Future<void> aggiornaSquadriglia(Squadriglia s) => eseguiSupabase(() async {
        await supabase.from('squads').update({
          'nome': s.nome.trim(),
          'urlo': s.urlo.trim(),
          'is_active': s.attiva,
        }).eq('id', s.id);
        _cache.dimentica(const ['sottogruppi', 'ragazzi', 'squadriglie']);
        notifyListeners();
      });

  @override
  Future<void> salvaMembri(TipoSottogruppo tipo, Set<String> membri) =>
      eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) throw sessioneSenzaUnita;
        await supabase.rpc('salva_membri_sottogruppo', params: {
          'p_unit_id': unitId,
          'p_tipo': tipo.valoreDb,
          'p_membri': membri.toList(),
        });
        _cache.dimentica(const ['sottogruppi', 'ragazzi', 'squadriglie']);
        notifyListeners();
      });
}
