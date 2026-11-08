import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/veglia.dart';
import '../../domain/repositories/veglia_repository.dart';

/// Veglie su Supabase (tabella `veglie`); le scrive solo l'Assistente.
class SupabaseVegliaRepository extends IVegliaRepository {
  final SessionService _session;
  SupabaseVegliaRepository(this._session);

  @override
  Future<List<Veglia>> getVeglie() => eseguiSupabase(() async {
        final groupId = _session.groupId;
        if (groupId == null) return [];
        final List<dynamic> righe = await supabase
            .from('veglie')
            .select()
            .eq('group_id', groupId)
            .order('updated_at', ascending: false);
        return [
          for (final r in righe)
            Veglia(
              id: r['id'] as String,
              titolo: (r['titolo'] ?? '') as String,
              branca: BrancaVeglia.daDb(r['branca']),
              momenti: momentiDaJson(r['struttura']),
            ),
        ];
      });

  /// Momenti letti da `veglie.struttura`; un valore malformato non blocca.
  static List<MomentoVeglia> momentiDaJson(Object? struttura) => [
        if (struttura is List)
          for (final m in struttura.whereType<Map>())
            MomentoVeglia(
              tipo: TipoMomento.daNome(m['tipo']),
              testo: (m['testo'] ?? '') as String,
            ),
      ];

  @override
  Future<void> salva(Veglia v) => eseguiSupabase(() async {
        final dati = {
          'titolo': v.titolo.trim(),
          'branca': v.branca.valoreDb,
          'struttura': [
            for (final m in v.momenti) {'tipo': m.tipo.name, 'testo': m.testo},
          ],
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };
        if (v.id.isEmpty) {
          final groupId = _session.groupId;
          if (groupId == null) throw sessioneSenzaUnita;
          await supabase.from('veglie').insert({...dati, 'group_id': groupId});
        } else {
          await supabase.from('veglie').update(dati).eq('id', v.id);
        }
        notifyListeners();
      });

  @override
  Future<void> elimina(String id) => eseguiSupabase(() async {
        await supabase.from('veglie').delete().eq('id', id);
        notifyListeners();
      });
}
