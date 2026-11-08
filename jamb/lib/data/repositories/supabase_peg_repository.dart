import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/peg.dart';
import '../../domain/repositories/peg_repository.dart';

/// Progetto Educativo di Gruppo su Supabase; le RLS riservano la scrittura al
/// Capo Gruppo e decidono di quali unità si leggono i gradi.
class SupabasePegRepository extends IPegRepository {
  final SessionService _session;
  SupabasePegRepository(this._session);

  String get _gruppo {
    final id = _session.groupId;
    if (id == null) throw sessioneSenzaUnita;
    return id;
  }

  @override
  Future<Peg> getPeg() => eseguiSupabase(() async {
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
        notifyListeners();
      });

  @override
  Future<List<PegObiettivo>> getObiettivi() => eseguiSupabase(() async {
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
        notifyListeners();
      });

  @override
  Future<void> aggiornaObiettivo(PegObiettivo o) => eseguiSupabase(() async {
        await supabase
            .from('peg_obiettivi')
            .update({'titolo': o.titolo.trim(), 'descrizione': o.descrizione.trim()})
            .eq('id', o.id);
        notifyListeners();
      });

  @override
  Future<void> eliminaObiettivo(String id) => eseguiSupabase(() async {
        await supabase.from('peg_obiettivi').delete().eq('id', id);
        notifyListeners();
      });

  @override
  Future<List<GradoCollegato>> getGradiCollegati() => eseguiSupabase(() async {
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
