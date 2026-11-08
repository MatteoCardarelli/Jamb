import 'package:flutter/material.dart';
import 'package:jamb/core/categoria_evento_colori.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/data/services/file_archiviati.dart' show idCasuale;
import '../../domain/entities/evento.dart';
import '../../domain/repositories/evento_repository.dart';

/// Repository degli eventi del calendario su Supabase (tabella `events`).
///
/// I filtri per data ([getEventiPerData], [getEventiTraDate]) sono applicati
/// lato client riusando [getEventi]: i volumi sono piccoli.
class SupabaseEventoRepository extends IEventoRepository {
  final SessionService _session;
  SupabaseEventoRepository(this._session);

  static const String _table = 'events';

  @override
  Future<List<Evento>> getEventi() => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final groupId = _session.groupId;
        if (groupId == null) return [];
        // Tutti gli eventi del gruppo: ogni capo vede quelli di ogni branca.
        final List<dynamic> rows = await supabase
            .from(_table)
            .select('*, units ( tipo_branca, nome )')
            .eq('group_id', groupId)
            .order('data_inizio', ascending: true);
        return rows.map((r) => _fromDb(r as Map<String, dynamic>)).toList();
      });

  @override
  Future<List<Evento>> getEventiPerData(DateTime data) async {
    final eventi = await getEventi();
    final target = DateTime(data.year, data.month, data.day);
    return eventi.where((e) {
      final start = DateTime(e.dataInizio.year, e.dataInizio.month, e.dataInizio.day);
      final end = DateTime(e.dataFine.year, e.dataFine.month, e.dataFine.day);
      return (target.isAfter(start) || target.isAtSameMomentAs(start)) &&
             (target.isBefore(end) || target.isAtSameMomentAs(end));
    }).toList();
  }

  @override
  Future<List<Evento>> getEventiTraDate(DateTime dal, DateTime al) async {
    final eventi = await getEventi();
    return eventi.where((e) =>
        (e.dataInizio.isAfter(dal) || e.dataInizio.isAtSameMomentAs(dal)) &&
        (e.dataInizio.isBefore(al) || e.dataInizio.isAtSameMomentAs(al))).toList();
  }

  static const Map<Ripetizione, String> _ripetizioniDb = {
    Ripetizione.ogniGiorno: 'giornaliera',
    Ripetizione.ogniSettimana: 'settimanale',
    Ripetizione.ogniMese: 'mensile',
    Ripetizione.ogniAnno: 'annuale',
  };

  /// Valore di `events.ripetizione` per [r] (`null` per un evento singolo).
  static String? valoreDbRipetizione(Ripetizione r) => _ripetizioniDb[r];

  /// Ripetizione corrispondente al valore del DB; sconosciuto → [Ripetizione.mai].
  static Ripetizione ripetizioneDaDb(Object? valore) {
    for (final voce in _ripetizioniDb.entries) {
      if (voce.value == valore) return voce.key;
    }
    return Ripetizione.mai;
  }

  @override
  Future<void> creaEvento(
    Evento evento, {
    Ripetizione ripetizione = Ripetizione.mai,
    DateTime? finoAl,
  }) =>
      eseguiSupabase(() async {
        final diCoca = evento.livello == LivelloEvento.coca;
        if (diCoca && _session.unitaCocaId == null) throw gruppoSenzaCoca;
        final serie = ripetizione == Ripetizione.mai
            ? [evento]
            : eventiDellaSerie(evento, ripetizione, finoAl ?? evento.dataInizio);
        final serieId = ripetizione == Ripetizione.mai ? null : idCasuale();
        // Tutte le date in un'unica scrittura: o tutte o nessuna.
        await supabase.from(_table).insert([
          for (final e in serie)
            {
              'group_id': _session.groupId,
              'unit_id': diCoca ? _session.unitaCocaId : _session.activeUnitId,
              'tipo_evento': 'RIUNIONE', // l'entità non modella il tipo: valore di default
              'serie_id': serieId,
              'ripetizione': valoreDbRipetizione(ripetizione),
              ..._campiModificabili(e),
            },
        ]);
        notifyListeners();
      });

  @override
  Future<void> aggiornaEvento(Evento evento, {AmbitoSerie ambito = AmbitoSerie.soloQuesto}) =>
      eseguiSupabase(() async {
        if (ambito == AmbitoSerie.soloQuesto || !evento.inSerie) {
          await supabase.from(_table).update(_campiModificabili(evento)).eq('id', evento.id);
        } else {
          // I successivi si contano dalla data dell'evento prima della modifica.
          final Map<String, dynamic> originale =
              await supabase.from(_table).select().eq('id', evento.id).single();
          final List<dynamic> successivi = await supabase
              .from(_table)
              .select()
              .eq('serie_id', evento.serieId!)
              .gt('data_inizio', originale['data_inizio'] as String)
              .neq('id', evento.id);
          // Una sola scrittura per l'evento modificato e i successivi. Le
          // righe sono complete perché un upsert passa anche dai controlli
          // dell'inserimento (colonne obbligatorie e policy).
          await supabase.from(_table).upsert([
            {...originale, ..._campiModificabili(evento)},
            for (final r in successivi.cast<Map<String, dynamic>>())
              {...r, ..._campiModificabili(applicaAllaSerie(evento, _fromDb(r)))},
          ]);
        }
        notifyListeners();
      });

  @override
  Future<void> eliminaEvento(Evento evento, {AmbitoSerie ambito = AmbitoSerie.soloQuesto}) =>
      eseguiSupabase(() async {
        if (ambito == AmbitoSerie.soloQuesto || !evento.inSerie) {
          await supabase.from(_table).delete().eq('id', evento.id);
        } else {
          await supabase
              .from(_table)
              .delete()
              .eq('serie_id', evento.serieId!)
              .gte('data_inizio', evento.dataInizio.toIso8601String());
        }
        notifyListeners();
      });

  /// Colonne che l'utente può impostare dal form (lo scope resta quello di creazione).
  Map<String, dynamic> _campiModificabili(Evento evento) => {
        'titolo': evento.titolo,
        'categorie_tematiche': evento.categorie,
        'data_inizio': evento.dataInizio.toIso8601String(),
        'data_fine': evento.dataFine.toIso8601String(),
        'luogo': evento.luogo,
        'tutto_il_giorno': evento.tuttoIlGiorno,
      };

  /// Costruisce un [Evento] a partire da una riga del database.
  Evento _fromDb(Map<String, dynamic> row) {
    final categorie = _asList(row['categorie_tematiche'])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return Evento(
      id: row['id'] as String,
      titolo: (row['titolo'] ?? '') as String,
      dataInizio: DateTime.parse(row['data_inizio'] as String),
      dataFine: DateTime.parse(row['data_fine'] as String),
      luogo: (row['luogo'] ?? '') as String,
      categorie: categorie,
      colorePrincipale: categorie.isNotEmpty
          ? coloreCategoria(categorie.first)
          : const Color(0xFF25315B),
      tuttoIlGiorno: row['tutto_il_giorno'] == true,
      serieId: row['serie_id'] as String?,
      ripetizione: ripetizioneDaDb(row['ripetizione']),
      livello: livelloDaDb(row['unit_id'], row['units'], _session.activeUnitId),
      nomeUnita: (row['units'] as Map?)?['nome'] as String?,
    );
  }

  /// Livello di un evento: senza unità è di gruppo; l'unità COCA è la Co.Ca.;
  /// altrimenti è dell'unità attiva o di un'altra unità, che resta in sola
  /// lettura anche se il suo tipo è sconosciuto.
  @visibleForTesting
  static LivelloEvento livelloDaDb(Object? unitId, Object? unita, String? unitaAttiva) {
    if (unitId == null) return LivelloEvento.gruppo;
    if (unita is Map && unita['tipo_branca'] == 'COCA') return LivelloEvento.coca;
    return unitId == unitaAttiva ? LivelloEvento.unita : LivelloEvento.altraUnita;
  }

  /// Normalizza un valore JSONB in lista (vuota se non è una lista).
  List<dynamic> _asList(dynamic v) => v is List ? v : const [];
}
