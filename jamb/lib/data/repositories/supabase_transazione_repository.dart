import 'package:flutter/foundation.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/data/services/file_archiviati.dart';
import 'package:jamb/data/services/storage_service.dart';
import '../../domain/entities/bilancio.dart';
import '../../domain/entities/file_da_caricare.dart';
import '../../domain/entities/transazione.dart';
import '../../domain/repositories/transazione_repository.dart';

/// Repository delle transazioni di cassa su Supabase (tabella `transactions`).
///
/// Legge e scrive la cassa dell'unità attiva, presa dalla sessione; le RLS
/// restano il controllo d'accesso. Le foto degli scontrini sono nel bucket
/// privato `ricevute`; `receipt_url` ne contiene il percorso.
class SupabaseTransazioneRepository extends ITransazioneRepository {
  final SessionService _session;
  final IStorageService _storage;
  SupabaseTransazioneRepository(this._session, this._storage);

  static const String _table = 'transactions';

  /// Distingue un UUID reale (transazione già sul DB) da un id temporaneo
  /// generato dalla UI con `millisecondsSinceEpoch` (transazione nuova).
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  Future<List<Transazione>> getTransazioni() => eseguiSupabase(() async {
        final unitId = _session.activeUnitId;
        if (unitId == null) return [];
        final List<dynamic> rows = await supabase
            .from(_table)
            .select()
            .eq('unit_id', unitId)
            .order('data', ascending: false);
        return rows.map((row) => _fromDb(row as Map<String, dynamic>)).toList();
      });

  @override
  Future<List<CassaDelGruppo>> getCasseDelGruppo() => eseguiSupabase(() async {
        final groupId = _session.groupId;
        if (groupId == null) return [];
        final List<dynamic> unita = await supabase
            .from('units')
            .select('id, nome')
            .eq('group_id', groupId)
            .neq('tipo_branca', 'COCA')
            .order('nome');
        final ids = [for (final u in unita) u['id'] as String];

        final List<dynamic> righe = await supabase
            .from(_table)
            .select()
            .or([
              'group_id.eq.$groupId',
              if (ids.isNotEmpty) 'unit_id.in.(${ids.join(',')})',
            ].join(','));

        final perUnita = <String, List<Transazione>>{};
        final delGruppo = <Transazione>[];
        for (final r in righe.cast<Map<String, dynamic>>()) {
          final unitId = r['unit_id'] as String?;
          if (unitId == null) {
            delGruppo.add(_fromDb(r));
          } else {
            perUnita.putIfAbsent(unitId, () => []).add(_fromDb(r));
          }
        }
        return [
          for (final u in unita)
            CassaDelGruppo(
              nome: (u['nome'] ?? '') as String,
              transazioni: perUnita[u['id']] ?? const [],
            ),
          if (delGruppo.isNotEmpty) CassaDelGruppo(nome: 'Cassa di Gruppo', transazioni: delGruppo),
        ];
      });

  @override
  Future<void> salvaTransazione(Transazione t, {FileDaCaricare? ricevuta}) =>
      eseguiSupabase(() async {
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) throw sessioneSenzaUtente;

        // id non-UUID → nuova (INSERT, id generato dal DB); id UUID → esistente (UPDATE).
        final bool isNuova = !_uuidRegex.hasMatch(t.id);

        if (isNuova) {
          final unitId = _session.activeUnitId;
          final groupId = _session.groupId;
          if (unitId == null || groupId == null) throw sessioneSenzaUnita;

          Future<void> inserisci(String? percorsoRicevuta) =>
              supabase.from(_table).insert({
                'autore_id': userId,
                'unit_id': unitId,
                'tipo': t.isUscita ? 'USCITA' : 'ENTRATA',
                'importo': t.importo,
                'titolo': t.titolo,
                'categoria': t.categoria.name,
                'note': t.note,
                'receipt_url': percorsoRicevuta,
                'data': t.data.toIso8601String(),
              });

          if (ricevuta == null) {
            await inserisci(null);
          } else {
            // Prima la foto, poi la riga; se la riga non si salva la foto
            // viene eliminata.
            final mime = verificaFile(ricevuta.nome, ricevuta.dimensione,
                ammessi: mimeRicevute, limite: limiteRicevute);
            final percorso = percorsoFile(
              gruppo: groupId,
              cartella: unitId,
              id: idCasuale(),
              estensione: estensioneDi(ricevuta.nome),
            );
            await caricaConCompensazione(
              caricaFile: () => _storage.carica(bucketRicevute, percorso, ricevuta.byte, mime),
              scriviRiga: () => inserisci(percorso),
              eliminaFile: () => _storage.elimina(bucketRicevute, [percorso]),
            );
          }
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
      });

  @override
  Future<void> eliminaTransazione(String id) => eseguiSupabase(() async {
        final List<dynamic> eliminate =
            await supabase.from(_table).delete().eq('id', id).select('receipt_url');
        notifyListeners();

        // Prima la riga, poi la foto: se l'eliminazione della foto fallisce
        // resta un file orfano (privato e invisibile), mai una transazione
        // che punta a una foto inesistente.
        final percorsi = [
          for (final r in eliminate)
            if (r['receipt_url'] case final String percorso) percorso,
        ];
        try {
          await _storage.elimina(bucketRicevute, percorsi);
        } catch (e) {
          debugPrint('Ricevuta orfana dopo l\'eliminazione della transazione $id: $e');
        }
      });

  @override
  Future<String> urlRicevuta(String percorso) =>
      _storage.urlFirmato(bucketRicevute, percorso);

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
