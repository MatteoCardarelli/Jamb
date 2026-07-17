import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import '../../domain/entities/documento.dart';
import '../../domain/repositories/documento_repository.dart';

/// Repository dei documenti su Supabase (tabella `documents`).
///
/// Rappresenta un albero di cartelle e file tramite self-join su `parent_id`,
/// filtrato per l'unità attiva.
class SupabaseDocumentoRepository implements IDocumentoRepository {
  final SessionService _session;
  SupabaseDocumentoRepository(this._session);

  static const String _table = 'documents';

  @override
  Future<List<Documento>> getContenuto(String? parentId) async {
    final unitId = _session.activeUnitId;
    if (unitId == null) return [];

    // Radice → parent_id IS NULL; altrimenti figli della cartella indicata.
    var filter = supabase.from(_table).select().eq('unit_id', unitId);
    filter = parentId == null
        ? filter.isFilter('parent_id', null)
        : filter.eq('parent_id', parentId);

    // Cartelle prima dei file, poi in ordine alfabetico di titolo.
    final List<dynamic> rows =
        await filter.order('is_cartella', ascending: false).order('titolo');
    return rows.map((r) => _fromDb(r as Map<String, dynamic>)).toList();
  }

  /// Costruisce un [Documento] a partire da una riga del database.
  Documento _fromDb(Map<String, dynamic> row) {
    final isCartella = (row['is_cartella'] ?? false) as bool;
    return Documento(
      id: row['id'] as String,
      nome: (row['titolo'] ?? '') as String,
      tipo: isCartella
          ? TipoDocumento.cartella
          : TipoDocumento.safeByName(row['tipo_file'] as String?),
      parentId: row['parent_id'] as String?,
      dimensioni: (row['dimensioni'] as num?)?.toInt(),
      ultimaModifica: _parseDate(row['ultima_modifica']) ??
          _parseDate(row['data_caricamento']) ??
          DateTime.now(),
    );
  }

  /// Converte una stringa data del DB in [DateTime] (null se assente/non valida).
  DateTime? _parseDate(dynamic v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
}
