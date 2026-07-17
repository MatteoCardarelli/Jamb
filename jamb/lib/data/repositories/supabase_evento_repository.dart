import 'package:flutter/material.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
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
  Future<List<Evento>> getEventi() async {
    final List<dynamic> rows =
        await supabase.from(_table).select().order('data_inizio', ascending: true);
    return rows.map((r) => _fromDb(r as Map<String, dynamic>)).toList();
  }

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

  @override
  Future<void> creaEvento(Evento evento) async {
    await supabase.from(_table).insert({
      'group_id': _session.groupId,
      'unit_id': _session.activeUnitId,
      'titolo': evento.titolo,
      'tipo_evento': 'RIUNIONE', // l'entità non modella il tipo: valore di default
      'categorie_tematiche': evento.categorie.map((c) => c.name).toList(),
      'data_inizio': evento.dataInizio.toIso8601String(),
      'data_fine': evento.dataFine.toIso8601String(),
      'luogo': evento.luogo,
    });
    notifyListeners();
  }

  /// Costruisce un [Evento] a partire da una riga del database.
  Evento _fromDb(Map<String, dynamic> row) {
    final categorie = _asList(row['categorie_tematiche'])
        .map((e) => _categoriaFromDb(e as String))
        .toList();
    return Evento(
      id: row['id'] as String,
      titolo: (row['titolo'] ?? '') as String,
      dataInizio: DateTime.parse(row['data_inizio'] as String),
      dataFine: DateTime.parse(row['data_fine'] as String),
      luogo: (row['luogo'] ?? '') as String,
      categorie: categorie,
      colorePrincipale:
          categorie.isNotEmpty ? categorie.first.textColor : const Color(0xFF25315B),
    );
  }

  /// Converte il nome di una categoria dal DB nell'enum corrispondente.
  CategoriaEvento _categoriaFromDb(String value) {
    for (final c in CategoriaEvento.values) {
      if (c.name == value) return c;
    }
    return CategoriaEvento.fromString(value); // fallback sul nome visualizzato
  }

  /// Normalizza un valore JSONB in lista (vuota se non è una lista).
  List<dynamic> _asList(dynamic v) => v is List ? v : const [];
}
