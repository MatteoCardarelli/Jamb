import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import '../../domain/entities/avviso.dart';
import '../../domain/repositories/avviso_repository.dart';

/// Repository della bacheca su Supabase (tabelle `notice_board` e `notice_reads`).
///
/// Legge solo gli avvisi di tipo `AVVISO` dell'unità attiva: `CAPITOLO` e
/// `SERVIZIO` sono bacheche della branca R/S, non ancora presenti nell'app.
/// Lo stato di lettura arriva nella stessa query: le RLS di `notice_reads`
/// restituiscono solo le righe dell'utente loggato.
class SupabaseAvvisoRepository extends IAvvisoRepository {
  final SessionService _session;
  SupabaseAvvisoRepository(this._session);

  static const String _table = 'notice_board';

  @override
  Future<List<Avviso>> getAvvisi() => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];

        // L'autore va indicato per vincolo: `users` è raggiungibile anche
        // attraverso `notice_reads`, e PostgREST non saprebbe quale scegliere.
        final List<dynamic> rows = await supabase
            .from(_table)
            .select('''
              id, titolo, contenuto, data_pubblicazione, autore_id,
              autore:users!notice_board_autore_id_fkey ( nome, cognome ),
              squads ( nome ),
              notice_reads ( user_id )
            ''')
            .eq('unit_id', unitId)
            .eq('tipo_post', 'AVVISO')
            .order('data_pubblicazione', ascending: false);
        return rows.map((r) => _fromDb(r as Map<String, dynamic>)).toList();
      });

  @override
  Future<void> creaAvviso(Avviso avviso) => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) throw sessioneSenzaUnita;
        // L'autore è impostato dal database (default auth.uid()).
        await supabase.from(_table).insert({
          'unit_id': unitId,
          'tipo_post': 'AVVISO',
          ...await _campiModificabili(avviso, unitId),
        });
        notifyListeners();
      });

  @override
  Future<void> aggiornaAvviso(Avviso avviso) => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) throw sessioneSenzaUnita;
        await supabase
            .from(_table)
            .update(await _campiModificabili(avviso, unitId))
            .eq('id', avviso.id);
        notifyListeners();
      });

  @override
  Future<void> eliminaAvviso(String id) => eseguiSupabase(() async {
        await supabase.from(_table).delete().eq('id', id);
        notifyListeners();
      });

  @override
  Future<void> segnaComeLetto(String id) => eseguiSupabase(() async {
        // Una lettura già registrata non è un errore.
        await supabase
            .from('notice_reads')
            .upsert({'notice_id': id}, ignoreDuplicates: true);
        notifyListeners();
      });

  /// Colonne impostate dal form; la squadriglia passa dal nome all'id.
  Future<Map<String, dynamic>> _campiModificabili(
    Avviso avviso,
    String unitId,
  ) async =>
      {
        'titolo': avviso.titolo,
        'contenuto': avviso.contenuto,
        'squad_id': avviso.squadriglia == null
            ? null
            : await _idSquadriglia(avviso.squadriglia!, unitId),
      };

  /// Id della squadriglia attiva [nome] nell'unità [unitId].
  Future<String> _idSquadriglia(String nome, String unitId) async {
    final row = await supabase
        .from('squads')
        .select('id')
        .eq('unit_id', unitId)
        .eq('nome', nome)
        .eq('is_active', true)
        .maybeSingle();
    if (row == null) {
      throw JambException(
        TipoErrore.datiNonValidi,
        'La squadriglia $nome non esiste più.',
      );
    }
    return row['id'] as String;
  }

  /// Costruisce un [Avviso] da una riga con autore, squadriglia e letture.
  Avviso _fromDb(Map<String, dynamic> row) {
    final autore = row['autore'] as Map<String, dynamic>?;
    final squadriglia = row['squads'] as Map<String, dynamic>?;
    final letture = row['notice_reads'];
    final scrittoDaMe = row['autore_id'] == _session.userId;

    return Avviso(
      id: row['id'] as String,
      titolo: (row['titolo'] ?? '') as String,
      contenuto: (row['contenuto'] ?? '') as String,
      dataPubblicazione:
          DateTime.parse(row['data_pubblicazione'] as String).toLocal(),
      autore: [autore?['nome'], autore?['cognome']]
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .join(' '),
      squadriglia: squadriglia?['nome'] as String?,
      letto: scrittoDaMe || (letture is List && letture.isNotEmpty),
    );
  }
}
