import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/anno_scout.dart';
import '../../domain/entities/campo.dart';
import '../../domain/repositories/campo_repository.dart';

/// Programmazione del campo su Supabase, per l'unità attiva e l'anno scout in corso.
class SupabaseCampoRepository extends ICampoRepository {
  final SessionService _session;
  SupabaseCampoRepository(this._session);

  static String? _soloData(DateTime? d) => d?.toIso8601String().split('T').first;

  @override
  Future<Campo?> getCampo() => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return null;
        final r = await supabase
            .from('campi')
            .select()
            .eq('unit_id', unitId)
            .eq('anno_scout', annoScoutDi(DateTime.now()))
            .maybeSingle();
        if (r == null) return null;
        return Campo(
          id: r['id'] as String,
          titolo: (r['titolo'] ?? '') as String,
          luogo: (r['luogo'] ?? '') as String,
          dataInizio: r['data_inizio'] == null ? null : DateTime.parse(r['data_inizio'] as String),
          dataFine: r['data_fine'] == null ? null : DateTime.parse(r['data_fine'] as String),
        );
      });

  @override
  Future<void> creaCampo(String titolo) => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) throw sessioneSenzaUnita;
        await supabase.from('campi').insert({
          'unit_id': unitId,
          'anno_scout': annoScoutDi(DateTime.now()),
          'titolo': titolo.trim(),
        });
        notifyListeners();
      });

  @override
  Future<void> aggiornaCampo(Campo c) => eseguiSupabase(() async {
        await supabase.from('campi').update({
          'titolo': c.titolo.trim(),
          'luogo': c.luogo.trim(),
          'data_inizio': _soloData(c.dataInizio),
          'data_fine': _soloData(c.dataFine),
        }).eq('id', c.id);
        notifyListeners();
      });

  @override
  Future<List<Pattuglia>> getPattuglie(String campoId) => eseguiSupabase(() async {
        final List<dynamic> righe = await supabase
            .from('campo_pattuglie')
            .select()
            .eq('campo_id', campoId)
            .order('created_at');
        return [
          for (final r in righe) Pattuglia(id: r['id'] as String, nome: (r['nome'] ?? '') as String),
        ];
      });

  @override
  Future<void> creaPattuglia(String campoId, String nome) => eseguiSupabase(() async {
        await supabase.from('campo_pattuglie').insert({'campo_id': campoId, 'nome': nome.trim()});
        notifyListeners();
      });

  @override
  Future<void> rinominaPattuglia(String id, String nome) => eseguiSupabase(() async {
        await supabase.from('campo_pattuglie').update({'nome': nome.trim()}).eq('id', id);
        notifyListeners();
      });

  @override
  Future<void> eliminaPattuglia(String id) => eseguiSupabase(() async {
        await supabase.from('campo_pattuglie').delete().eq('id', id);
        notifyListeners();
      });

  @override
  Future<List<CompitoCampo>> getCompiti(Iterable<String> pattuglie) => eseguiSupabase(() async {
        if (pattuglie.isEmpty) return [];
        final List<dynamic> righe = await supabase
            .from('campo_compiti')
            .select()
            .inFilter('pattuglia_id', pattuglie.toList())
            .order('created_at');
        return [
          for (final r in righe)
            CompitoCampo(
              id: r['id'] as String,
              pattugliaId: r['pattuglia_id'] as String,
              titolo: (r['titolo'] ?? '') as String,
              stato: StatoCompito.daDb(r['stato']),
            ),
        ];
      });

  @override
  Future<void> creaCompito(String pattugliaId, String titolo) => eseguiSupabase(() async {
        await supabase.from('campo_compiti').insert({'pattuglia_id': pattugliaId, 'titolo': titolo.trim()});
        notifyListeners();
      });

  @override
  Future<void> impostaStato(String id, StatoCompito stato) => eseguiSupabase(() async {
        await supabase.from('campo_compiti').update({'stato': stato.valoreDb}).eq('id', id);
        notifyListeners();
      });

  @override
  Future<void> eliminaCompito(String id) => eseguiSupabase(() async {
        await supabase.from('campo_compiti').delete().eq('id', id);
        notifyListeners();
      });
}
