import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/presenza.dart';
import '../../domain/repositories/presenza_repository.dart';

/// Repository dell'appello su Supabase (tabella `event_attendances`).
///
/// Gli stati `INVITATO` e `CONFERMATO` (adesioni, non usate dall'app) e i
/// valori sconosciuti sono trattati come «non segnato».
class SupabasePresenzaRepository extends IPresenzaRepository {
  static const String _table = 'event_attendances';

  static const Map<StatoPresenza, String> _valoriDb = {
    StatoPresenza.presente: 'PRESENTE',
    StatoPresenza.assente: 'ASSENTE',
    StatoPresenza.giustificato: 'GIUSTIFICATO',
  };

  /// Valore di `stato_presenza_enum` corrispondente a [stato].
  static String valoreDb(StatoPresenza stato) => _valoriDb[stato]!;

  /// Stato corrispondente al valore del DB (`null` se non è un esito d'appello).
  static StatoPresenza? statoDaDb(Object? valore) {
    for (final voce in _valoriDb.entries) {
      if (voce.value == valore) return voce.key;
    }
    return null;
  }

  @override
  Future<Map<String, StatoPresenza>> getAppello(String eventoId) =>
      eseguiSupabase(() async {
        final List<dynamic> rows = await supabase
            .from(_table)
            .select('user_id, stato_presenza')
            .eq('event_id', eventoId);
        return {
          // Le righe senza un esito d'appello sono omesse.
          for (final r in rows)
            r['user_id'] as String: ?statoDaDb(r['stato_presenza']),
        };
      });

  @override
  Future<void> salvaAppello(String eventoId, Map<String, StatoPresenza> stati) =>
      eseguiSupabase(() async {
        if (stati.isEmpty) return;
        await supabase.from(_table).upsert(
          [
            for (final voce in stati.entries)
              {
                'event_id': eventoId,
                'user_id': voce.key,
                'stato_presenza': valoreDb(voce.value),
              },
          ],
          onConflict: 'event_id,user_id',
        );
        notifyListeners();
      });

  @override
  Future<List<PresenzaRagazzo>> getStorico(String ragazzoId) =>
      eseguiSupabase(() async {
        final List<dynamic> rows = await supabase
            .from(_table)
            .select('stato_presenza, events!inner ( id, titolo, data_inizio )')
            .eq('user_id', ragazzoId);

        final storico = <PresenzaRagazzo>[];
        for (final r in rows) {
          final stato = statoDaDb(r['stato_presenza']);
          final evento = r['events'] as Map<String, dynamic>?;
          if (stato == null || evento == null) continue;
          storico.add(PresenzaRagazzo(
            eventoId: evento['id'] as String,
            titoloEvento: (evento['titolo'] ?? '') as String,
            dataEvento: DateTime.parse(evento['data_inizio'] as String),
            stato: stato,
          ));
        }
        storico.sort((a, b) => b.dataEvento.compareTo(a.dataEvento));
        return storico;
      });
}
