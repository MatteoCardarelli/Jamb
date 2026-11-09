import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/cache_letture.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/pillola.dart';
import '../../domain/repositories/pillola_repository.dart';

/// Pillole del metodo su Supabase (tabella `pillole`, `tipo = metodo`), per
/// la branca dell'unità attiva; le RLS decidono chi le scrive.
class SupabasePillolaRepository extends IPillolaRepository {
  final SessionService _session;
  final CacheLetture _cache;
  SupabasePillolaRepository(this._session, this._cache);

  static const String _table = 'pillole';

  @override
  Future<List<Pillola>> getPillole({TipoPillola tipo = TipoPillola.metodo}) => _cache.leggiSupabase('pillole/${tipo.valoreDb}', () async {
        final branca = _session.tipoBrancaAttiva;
        final groupId = _session.groupId;
        if (groupId == null) return [];
        if (tipo == TipoPillola.metodo && branca == null) return [];
        final base = supabase.from(_table).select('id, testo, group_id').eq('tipo', tipo.valoreDb);
        final List<dynamic> righe = await (tipo == TipoPillola.metodo
                ? base.eq('branca', branca!).or('group_id.is.null,group_id.eq.$groupId')
                : base.eq('group_id', groupId))
            .order('created_at');
        return [
          for (final r in righe)
            Pillola(
              id: r['id'] as String,
              testo: (r['testo'] ?? '') as String,
              comune: r['group_id'] == null,
            ),
        ];
      });

  @override
  Future<void> crea(String testo, {TipoPillola tipo = TipoPillola.metodo}) => eseguiSupabase(() async {
        // Gli spunti di spiritualità sono rivolti alla Comunità Capi.
        final branca = tipo == TipoPillola.metodo ? _session.tipoBrancaAttiva : 'COCA';
        final groupId = _session.groupId;
        if (branca == null || groupId == null) throw sessioneSenzaUnita;
        await supabase.from(_table).insert({
          'group_id': groupId,
          'tipo': tipo.valoreDb,
          'branca': branca,
          'testo': testo.trim(),
        });
        _cache.dimentica(const ['pillole']);
        notifyListeners();
      });

  @override
  Future<void> aggiorna(String id, String testo) => eseguiSupabase(() async {
        await supabase.from(_table).update({'testo': testo.trim()}).eq('id', id);
        _cache.dimentica(const ['pillole']);
        notifyListeners();
      });

  @override
  Future<void> elimina(String id) => eseguiSupabase(() async {
        await supabase.from(_table).delete().eq('id', id);
        _cache.dimentica(const ['pillole']);
        notifyListeners();
      });
}
