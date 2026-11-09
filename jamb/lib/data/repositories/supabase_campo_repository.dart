import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/data/nome_completo.dart';
import '../../domain/entities/anno_scout.dart';
import '../../domain/entities/campo.dart';
import '../../domain/entities/sottogruppi.dart';
import '../../domain/repositories/campo_repository.dart';

/// Organizzazione dei campi su Supabase, per l'unità attiva.
class SupabaseCampoRepository extends ICampoRepository {
  final SessionService _session;
  SupabaseCampoRepository(this._session);

  static String? _soloData(DateTime? d) => d?.toIso8601String().split('T').first;

  Campo _campoDaDb(Map<String, dynamic> r) => Campo(
        id: r['id'] as String,
        tipo: TipoCampo.daDb(r['tipo']),
        annoScout: (r['anno_scout'] ?? '') as String,
        titolo: (r['titolo'] ?? '') as String,
        luogo: (r['luogo'] ?? '') as String,
        dataInizio: r['data_inizio'] == null ? null : DateTime.parse(r['data_inizio'] as String),
        dataFine: r['data_fine'] == null ? null : DateTime.parse(r['data_fine'] as String),
      );

  @override
  Future<List<Campo>> getCampi() => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final List<dynamic> righe = await supabase
            .from('campi')
            .select()
            .eq('unit_id', unitId)
            .order('created_at', ascending: false);
        return righe.cast<Map<String, dynamic>>().map(_campoDaDb).toList();
      });

  @override
  Future<Campo?> getCampo(String id) => eseguiSupabase(() async {
        final r = await supabase.from('campi').select().eq('id', id).maybeSingle();
        return r == null ? null : _campoDaDb(r);
      });

  @override
  Future<Campo> creaCampo(TipoCampo tipo, String titolo) => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) throw sessioneSenzaUnita;
        final r = await supabase
            .from('campi')
            .insert({
              'unit_id': unitId,
              'anno_scout': annoScoutDi(DateTime.now()),
              'tipo': tipo.valoreDb,
              'titolo': titolo.trim(),
            })
            .select()
            .single();
        notifyListeners();
        return _campoDaDb(r);
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
  Future<void> eliminaCampo(String id) => eseguiSupabase(() async {
        await supabase.from('campi').delete().eq('id', id);
        notifyListeners();
      });

  @override
  Future<List<MembroUnita>> getStaff() => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final List<dynamic> righe = await supabase
            .from('memberships')
            .select('user_id, ruolo, users ( nome, cognome )')
            .eq('unit_id', unitId)
            .eq('is_active', true)
            .inFilter('ruolo', const ['AIUTO_CAPO', 'CAPO_UNITA', 'CAPO_GRUPPO']);
        final staff = [
          for (final r in righe)
            MembroUnita(
              id: r['user_id'] as String,
              nome: nomeCompletoDa(r['users']),
              ruolo: (r['ruolo'] ?? '') as String,
            ),
        ];
        return staff..sort((a, b) => a.nome.compareTo(b.nome));
      });

  @override
  Future<List<Pattuglia>> getPattuglie(String campoId) => eseguiSupabase(() async {
        final List<dynamic> righe = await supabase
            .from('campo_pattuglie')
            .select('id, nome, campo_pattuglia_membri ( user_id )')
            .eq('campo_id', campoId)
            .order('created_at');
        return [
          for (final r in righe)
            Pattuglia(
              id: r['id'] as String,
              nome: (r['nome'] ?? '') as String,
              membri: {
                for (final m in (r['campo_pattuglia_membri'] as List? ?? const []))
                  m['user_id'] as String,
              },
            ),
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
  Future<void> salvaMembriPattuglia(String id, Set<String> membri) => eseguiSupabase(() async {
        await supabase.rpc('salva_membri_pattuglia', params: {
          'p_pattuglia_id': id,
          'p_membri': membri.toList(),
        });
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

  @override
  Future<List<ContattoCampo>> getContatti(String campoId) => eseguiSupabase(() async {
        final List<dynamic> righe = await supabase
            .from('campo_contatti')
            .select()
            .eq('campo_id', campoId)
            .order('created_at');
        return [
          for (final r in righe)
            ContattoCampo(
              id: r['id'] as String,
              etichetta: (r['etichetta'] ?? '') as String,
              telefono: (r['telefono'] ?? '') as String,
            ),
        ];
      });

  @override
  Future<void> creaContatto(String campoId, String etichetta, String telefono) =>
      eseguiSupabase(() async {
        await supabase.from('campo_contatti').insert({
          'campo_id': campoId,
          'etichetta': etichetta.trim(),
          'telefono': telefono.trim(),
        });
        notifyListeners();
      });

  @override
  Future<void> eliminaContatto(String id) => eseguiSupabase(() async {
        await supabase.from('campo_contatti').delete().eq('id', id);
        notifyListeners();
      });
}
