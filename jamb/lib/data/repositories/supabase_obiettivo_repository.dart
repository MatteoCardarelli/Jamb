import 'package:flutter/material.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import '../../domain/entities/obiettivo.dart';
import '../../domain/repositories/obiettivo_repository.dart';

/// Repository degli obiettivi educativi su Supabase (tabella `obiettivi_educativi`).
class SupabaseObiettivoRepository implements IObiettivoRepository {
  final SessionService _session;
  SupabaseObiettivoRepository(this._session);

  static const String _table = 'obiettivi_educativi';

  /// Distingue un UUID reale (obiettivo già a DB) da un id temporaneo
  /// generato dalla UI con `millisecondsSinceEpoch` (obiettivo nuovo).
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  Future<List<Obiettivo>> getObiettivi() async {
    final List<dynamic> rows =
        await supabase.from(_table).select().order('created_at', ascending: true);
    return rows.map((r) => _fromDb(r as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> salvaObiettivo(Obiettivo o) async {
    final payload = {
      'dominio': o.dominio,
      'descrizione': o.descrizione,
      'grado': o.grado,
      'diario_di_bordo': o.diarioDiBordo,
      'colore': o.colore.value,
      'icona': o.icona.codePoint,
    };

    // id non-UUID → nuovo (INSERT, id generato dal DB); id UUID → esistente (UPDATE).
    final bool isNuovo = !_uuidRegex.hasMatch(o.id);
    if (isNuovo) {
      final unitId = _session.activeUnitId;
      if (unitId == null) {
        throw StateError('Nessuna unità attiva: impossibile salvare.');
      }
      await supabase.from(_table).insert({
        ...payload,
        'unit_id': unitId,
        'anno_scout': _annoScoutCorrente(),
      });
    } else {
      await supabase.from(_table).update(payload).eq('id', o.id);
    }
  }

  @override
  Future<void> eliminaObiettivo(String id) async {
    await supabase.from(_table).delete().eq('id', id);
  }

  /// Costruisce un [Obiettivo] a partire da una riga del database.
  Obiettivo _fromDb(Map<String, dynamic> row) {
    return Obiettivo(
      id: row['id'] as String,
      dominio: (row['dominio'] ?? '') as String,
      descrizione: (row['descrizione'] ?? '') as String,
      grado: (row['grado'] as num?)?.toInt() ?? 0,
      diarioDiBordo: (row['diario_di_bordo'] ?? '') as String,
      colore: Color((row['colore'] as num?)?.toInt() ?? 0xFF1D2660),
      icona: IconData(
        (row['icona'] as num?)?.toInt() ?? Icons.star_rounded.codePoint,
        fontFamily: 'MaterialIcons',
      ),
    );
  }

  /// Anno scout corrente in formato "AAAA-AAAA" (l'annata va da settembre ad agosto).
  String _annoScoutCorrente() {
    final now = DateTime.now();
    final inizio = now.month >= 9 ? now.year : now.year - 1;
    return '$inizio-${inizio + 1}';
  }
}
