import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/core/session_service.dart';
import '../../domain/entities/transazione.dart';
import '../../domain/repositories/transazione_repository.dart';

/// Repository delle transazioni di cassa su Supabase (tabella `transactions`).
///
/// Le letture sono filtrate automaticamente dalla RLS in base all'utente
/// loggato; in scrittura lo scope (unità) viene preso dalla sessione.
class SupabaseTransazioneRepository extends ITransazioneRepository {
  final SessionService _session;
  SupabaseTransazioneRepository(this._session);

  static const String _table = 'transactions';

  /// Distingue un UUID reale (transazione già sul DB) da un id temporaneo
  /// generato dalla UI con `millisecondsSinceEpoch` (transazione nuova).
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  Future<List<Transazione>> getTransazioni() async {
    final List<dynamic> rows =
        await supabase.from(_table).select().order('data', ascending: false);
    return rows.map((row) => _fromDb(row as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> salvaTransazione(Transazione t) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Nessun utente loggato: impossibile salvare.');
    }

    // id non-UUID → nuova (INSERT, id generato dal DB); id UUID → esistente (UPDATE).
    final bool isNuova = !_uuidRegex.hasMatch(t.id);

    if (isNuova) {
      final unitId = _session.activeUnitId;
      if (unitId == null) {
        throw StateError('Nessuna unità attiva: impossibile salvare.');
      }
      await supabase.from(_table).insert({
        'autore_id': userId,
        'unit_id': unitId,
        'tipo': t.isUscita ? 'USCITA' : 'ENTRATA',
        'importo': t.importo,
        'titolo': t.titolo,
        'categoria': t.categoria.name,
        'note': t.note,
        'receipt_url': t.percorsoRicevuta,
        'data': t.data.toIso8601String(),
      });
    } else {
      await supabase.from(_table).update({
        'tipo': t.isUscita ? 'USCITA' : 'ENTRATA',
        'importo': t.importo,
        'titolo': t.titolo,
        'categoria': t.categoria.name,
        'note': t.note,
        'receipt_url': t.percorsoRicevuta,
        'data': t.data.toIso8601String(),
      }).eq('id', t.id);
    }

    notifyListeners();
  }

  @override
  Future<void> eliminaTransazione(String id) async {
    await supabase.from(_table).delete().eq('id', id);
    notifyListeners();
  }

  /// Costruisce una [Transazione] a partire da una riga del database.
  Transazione _fromDb(Map<String, dynamic> row) {
    return Transazione(
      id: row['id'] as String,
      titolo: (row['titolo'] ?? '') as String,
      importo: _toDouble(row['importo']),
      isUscita: (row['tipo'] as String) == 'USCITA',
      categoria: _categoriaFromDb(row['categoria'] as String?),
      data: row['data'] != null
          ? DateTime.parse(row['data'] as String)
          : DateTime.now(),
      note: (row['note'] ?? '') as String,
      percorsoRicevuta: row['receipt_url'] as String?,
      // NB: qui c'è l'UUID dell'autore; il nome leggibile richiederebbe un join a `users`.
      registratoDa: (row['autore_id'] ?? 'Utente') as String,
    );
  }

  /// Converte un valore numerico del DB (num o stringa) in `double`.
  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  /// Converte il nome della categoria dal DB; sconosciuto → [Categoria.altro].
  Categoria _categoriaFromDb(String? value) {
    if (value == null) return Categoria.altro;
    try {
      return Categoria.values.byName(value);
    } catch (_) {
      return Categoria.altro;
    }
  }
}
