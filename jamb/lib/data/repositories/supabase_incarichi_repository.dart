import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/incarichi.dart';
import '../../domain/repositories/incarichi_repository.dart';

/// Incarichi trasversali del gruppo su Supabase; solo il Capo Gruppo li modifica.
class SupabaseIncarichiRepository extends IIncarichiRepository {
  final SessionService _session;
  SupabaseIncarichiRepository(this._session);

  static const String _table = 'incarichi_trasversali';
  static const String _assistente = 'assistente_ecclesiastico';

  PersonaGruppo _persona(String id, Object? utente) {
    final u = utente is Map ? utente : const {};
    final nome = [u['nome'], u['cognome']]
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .join(' ');
    return PersonaGruppo(id: id, nome: nome.isEmpty ? 'Senza nome' : nome);
  }

  @override
  Future<List<PersonaGruppo>> getAssistenti() => eseguiSupabase(() async {
        final groupId = _session.groupId;
        if (groupId == null) return [];
        final List<dynamic> righe = await supabase
            .from(_table)
            .select('user_id, users!incarichi_trasversali_user_id_fkey ( nome, cognome )')
            .eq('group_id', groupId)
            .eq('tipo', _assistente);
        return [for (final r in righe) _persona(r['user_id'] as String, r['users'])];
      });

  @override
  Future<List<PersonaGruppo>> getPersone() => eseguiSupabase(() async {
        final groupId = _session.groupId;
        if (groupId == null) return [];
        final List<dynamic> righe =
            await supabase.from('users').select('id, nome, cognome').eq('group_id', groupId);
        return [for (final r in righe) _persona(r['id'] as String, r)];
      });

  @override
  Future<void> nomina(String userId) => eseguiSupabase(() async {
        final groupId = _session.groupId;
        if (groupId == null) throw sessioneSenzaUnita;
        await supabase.from(_table).insert({
          'user_id': userId,
          'group_id': groupId,
          'tipo': _assistente,
        });
        notifyListeners();
      });

  @override
  Future<void> revoca(String userId) => eseguiSupabase(() async {
        await supabase.from(_table).delete().eq('user_id', userId).eq('tipo', _assistente);
        notifyListeners();
      });
}
