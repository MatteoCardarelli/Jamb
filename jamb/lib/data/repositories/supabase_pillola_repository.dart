import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/pillola.dart';
import '../../domain/repositories/pillola_repository.dart';

/// Pillole del metodo su Supabase (tabella `pillole`, `tipo = metodo`), per
/// la branca dell'unità attiva; le RLS decidono chi le scrive.
class SupabasePillolaRepository extends IPillolaRepository {
  final SessionService _session;
  SupabasePillolaRepository(this._session);

  static const String _table = 'pillole';

  @override
  Future<List<Pillola>> getPillole() => eseguiSupabase(() async {
        final branca = _session.tipoBrancaAttiva;
        final groupId = _session.groupId;
        if (branca == null || groupId == null) return [];
        final List<dynamic> righe = await supabase
            .from(_table)
            .select('id, testo, group_id')
            .eq('tipo', 'metodo')
            .eq('branca', branca)
            .or('group_id.is.null,group_id.eq.$groupId')
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
  Future<void> crea(String testo) => eseguiSupabase(() async {
        final branca = _session.tipoBrancaAttiva;
        final groupId = _session.groupId;
        if (branca == null || groupId == null) throw sessioneSenzaUnita;
        await supabase.from(_table).insert({
          'group_id': groupId,
          'branca': branca,
          'testo': testo.trim(),
        });
        notifyListeners();
      });

  @override
  Future<void> aggiorna(String id, String testo) => eseguiSupabase(() async {
        await supabase.from(_table).update({'testo': testo.trim()}).eq('id', id);
        notifyListeners();
      });

  @override
  Future<void> elimina(String id) => eseguiSupabase(() async {
        await supabase.from(_table).delete().eq('id', id);
        notifyListeners();
      });
}
