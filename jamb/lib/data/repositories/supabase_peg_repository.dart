import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/cache_letture.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/peg.dart';
import '../../domain/repositories/peg_repository.dart';

/// Progetto Educativo di Gruppo su Supabase; le RLS riservano la scrittura al
/// Capo Gruppo e decidono di quali unità si leggono i gradi.
class SupabasePegRepository extends IPegRepository {
  final SessionService _session;
  final CacheLetture _cache;
  SupabasePegRepository(this._session, this._cache);

  String get _gruppo {
    final id = _session.groupId;
    if (id == null) throw sessioneSenzaUnita;
    return id;
  }

  @override
  Future<Peg> getPeg() => _cache.leggiSupabase('peg/intestazione', () async {
        final riga = await supabase.from('peg').select().eq('group_id', _gruppo).maybeSingle();
        if (riga == null) return const Peg();
        return Peg(
          titolo: (riga['titolo'] ?? '') as String,
          premessa: (riga['premessa'] ?? '') as String,
        );
      });

  @override
  Future<void> salvaPeg(Peg peg) => eseguiSupabase(() async {
        await supabase.from('peg').upsert({
          'group_id': _gruppo,
          'titolo': peg.titolo.trim(),
          'premessa': peg.premessa.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        _cache.dimentica(const ['peg/intestazione']);
        notifyListeners();
      });

  @override
  Future<List<PegObiettivo>> getObiettivi() => _cache.leggiSupabase('peg/obiettivi', () async {
        final List<dynamic> righe = await supabase
            .from('peg_obiettivi')
            .select()
            .eq('group_id', _gruppo)
            .order('created_at');
        return [
          for (final r in righe)
            PegObiettivo(
              id: r['id'] as String,
              titolo: (r['titolo'] ?? '') as String,
              descrizione: (r['descrizione'] ?? '') as String,
            ),
        ];
      });

  @override
  Future<void> creaObiettivo(String titolo, String descrizione) => eseguiSupabase(() async {
        await supabase.from('peg_obiettivi').insert({
          'group_id': _gruppo,
          'titolo': titolo.trim(),
          'descrizione': descrizione.trim(),
        });
        _cache.dimentica(const ['peg/obiettivi']);
        notifyListeners();
      });

  @override
  Future<void> aggiornaObiettivo(PegObiettivo o) => eseguiSupabase(() async {
        await supabase
            .from('peg_obiettivi')
            .update({'titolo': o.titolo.trim(), 'descrizione': o.descrizione.trim()})
            .eq('id', o.id);
        _cache.dimentica(const ['peg/obiettivi']);
        notifyListeners();
      });

  @override
  Future<void> eliminaObiettivo(String id) => eseguiSupabase(() async {
        await supabase.from('peg_obiettivi').delete().eq('id', id);
        _cache.dimentica(const ['peg/obiettivi', 'peg/gradi', 'obiettivi']);
        notifyListeners();
      });

  @override
  Future<List<GradoCollegato>> getGradiCollegati() => _cache.leggiSupabase('peg/gradi', () async {
        final List<dynamic> righe = await supabase
            .from('obiettivi_educativi')
            .select('peg_obiettivo_id, grado')
            .not('peg_obiettivo_id', 'is', null);
        return [
          for (final r in righe)
            GradoCollegato(
              pegObiettivoId: r['peg_obiettivo_id'] as String,
              grado: (r['grado'] as num?)?.toInt() ?? 1,
            ),
        ];
      });
}
