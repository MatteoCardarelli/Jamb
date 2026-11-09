import 'package:flutter/material.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/cache_letture.dart';
import 'package:jamb/data/errori_supabase.dart';
import '../../domain/entities/obiettivo.dart';
import '../../domain/repositories/obiettivo_repository.dart';

/// Repository degli obiettivi educativi su Supabase (tabella `obiettivi_educativi`).
class SupabaseObiettivoRepository implements IObiettivoRepository {
  final SessionService _session;
  final CacheLetture _cache;
  SupabaseObiettivoRepository(this._session, this._cache);

  static const String _table = 'obiettivi_educativi';

  /// Distingue un UUID reale (obiettivo già a DB) da un id temporaneo
  /// generato dalla UI con `millisecondsSinceEpoch` (obiettivo nuovo).
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  Future<List<Obiettivo>> getObiettivi() => _cache.leggiSupabase('obiettivi', () async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final List<dynamic> rows = await supabase
            .from(_table)
            .select()
            .eq('unit_id', unitId)
            .order('created_at', ascending: true);
        return rows.map((r) => _fromDb(r as Map<String, dynamic>)).toList();
      });

  @override
  Future<void> salvaObiettivo(Obiettivo o) => eseguiSupabase(() async {
        final payload = {
          'dominio': o.dominio,
          'descrizione': o.descrizione,
          'grado': o.grado,
          'diario_di_bordo': o.diarioDiBordo,
          'colore': o.colore.toARGB32(),
          'icona': o.icona.codePoint,
          'peg_obiettivo_id': o.pegObiettivoId,
        };

        // id non-UUID → nuovo (INSERT, id generato dal DB); id UUID → esistente (UPDATE).
        final bool isNuovo = !_uuidRegex.hasMatch(o.id);
        if (isNuovo) {
          final unitId = _session.activeUnitId;
          if (unitId == null) throw sessioneSenzaUnita;
          await supabase.from(_table).insert({
            ...payload,
            'unit_id': unitId,
            'anno_scout': _annoScoutCorrente(),
          });
        } else {
          await supabase.from(_table).update(payload).eq('id', o.id);
        }
        _cache.dimentica(const ['obiettivi', 'peg/gradi']);
      });

  @override
  Future<void> eliminaObiettivo(String id) => eseguiSupabase(() async {
        await supabase.from(_table).delete().eq('id', id);
        _cache.dimentica(const ['obiettivi', 'peg/gradi']);
      });

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
      pegObiettivoId: row['peg_obiettivo_id'] as String?,
    );
  }

  /// Anno scout corrente in formato "AAAA-AAAA" (l'annata va da settembre ad agosto).
  String _annoScoutCorrente() {
    final now = DateTime.now();
    final inizio = now.month >= 9 ? now.year : now.year - 1;
    return '$inizio-${inizio + 1}';
  }
}
