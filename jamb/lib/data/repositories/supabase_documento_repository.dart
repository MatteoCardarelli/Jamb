import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestFilterBuilder;
import 'package:jamb/core/session_service.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/data/services/file_archiviati.dart';
import 'package:jamb/data/services/storage_service.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import '../../domain/entities/documento.dart';
import '../../domain/entities/file_da_caricare.dart';
import '../../domain/repositories/documento_repository.dart';

/// Repository dei documenti su Supabase: righe in `documents` (albero per
/// `parent_id`), contenuti nel bucket privato `documenti`.
///
/// Ogni archivio è una sezione: i drive appartengono a un'unità (quella
/// attiva, o l'unità COCA del gruppo), le librerie al gruppo. Le RLS
/// decidono chi legge e chi scrive.
class SupabaseDocumentoRepository extends IDocumentoRepository {
  final SessionService _session;
  final IStorageService _storage;
  SupabaseDocumentoRepository(this._session, this._storage);

  static const String _table = 'documents';

  /// Proprietario delle righe di un archivio: sezione, unità e gruppo.
  Future<({String sezione, String? unitId, String groupId})> _proprietario(
    ArchivioDocumenti archivio,
  ) async {
    final groupId = _session.groupId;
    if (groupId == null) throw sessioneSenzaUnita;
    switch (archivio) {
      case ArchivioDocumenti.driveBranca:
        final unitId = _session.activeUnitId;
        if (unitId == null) throw sessioneSenzaUnita;
        return (sezione: 'drive', unitId: unitId, groupId: groupId);
      case ArchivioDocumenti.driveCoca:
        final unitId = _session.unitaCocaId;
        if (unitId == null) throw gruppoSenzaCoca;
        return (sezione: 'drive', unitId: unitId, groupId: groupId);
      case ArchivioDocumenti.metodoStatuto:
        return (sezione: 'metodo_statuto', unitId: null, groupId: groupId);
      case ArchivioDocumenti.modulistica:
        return (sezione: 'modulistica', unitId: null, groupId: groupId);
    }
  }

  /// Righe di [archivio] (tutte, o solo quelle filtrate dal chiamante).
  PostgrestFilterBuilder<List<Map<String, dynamic>>> _righe(
    ({String sezione, String? unitId, String groupId}) p,
  ) {
    final query = supabase
        .from(_table)
        .select()
        .eq('sezione', p.sezione)
        .eq('group_id', p.groupId);
    return p.unitId == null
        ? query.isFilter('unit_id', null)
        : query.eq('unit_id', p.unitId!);
  }

  @override
  Future<List<Documento>> getContenuto(ArchivioDocumenti archivio, String? parentId) =>
      eseguiSupabase(() async {
        final p = await _proprietario(archivio);
        final query = _righe(p);
        final List<dynamic> rows = parentId == null
            ? await query.isFilter('parent_id', null)
            : await query.eq('parent_id', parentId);
        return rows.map((r) => _fromDb(r as Map<String, dynamic>)).toList();
      });

  @override
  Future<List<Documento>> getRecenti({int quanti = 5}) => eseguiSupabase(() async {
        final p = await _proprietario(ArchivioDocumenti.driveBranca);
        final List<dynamic> rows = await _righe(p)
            .eq('is_cartella', false)
            .order('ultima_modifica', ascending: false)
            .limit(quanti);
        return rows.map((r) => _fromDb(r as Map<String, dynamic>)).toList();
      });

  @override
  Future<void> creaCartella(ArchivioDocumenti archivio, String nome, String? parentId) =>
      eseguiSupabase(() async {
        final p = await _proprietario(archivio);
        await supabase.from(_table).insert({
          ..._colonneProprietario(p),
          'parent_id': parentId,
          'is_cartella': true,
          'titolo': nome.trim(),
        });
        notifyListeners();
      });

  @override
  Future<Documento> caricaFile(ArchivioDocumenti archivio, FileDaCaricare file, String? parentId) =>
      eseguiSupabase(() async {
        final p = await _proprietario(archivio);
        final mime = verificaFile(file.nome, file.dimensione,
            ammessi: mimeDocumenti, limite: limiteDocumenti);
        final estensione = estensioneDi(file.nome);
        // Lo stesso id per la riga e per il nome del file nell'archivio.
        final id = idCasuale();
        final percorso = percorsoFile(
          gruppo: p.groupId,
          cartella: p.unitId ?? cartellaLibreria,
          id: id,
          estensione: estensione,
        );

        await caricaConCompensazione(
          caricaFile: () => _storage.carica(bucketDocumenti, percorso, file.byte, mime),
          scriviRiga: () => supabase.from(_table).insert({
            'id': id,
            ..._colonneProprietario(p),
            'parent_id': parentId,
            'is_cartella': false,
            'titolo': file.nome.trim(),
            'tipo_file': TipoDocumento.daEstensione(estensione).name,
            'file_url': percorso,
            'dimensioni': file.dimensione,
          }),
          eliminaFile: () => _storage.elimina(bucketDocumenti, [percorso]),
        );
        notifyListeners();
        return Documento(
          id: id,
          nome: file.nome.trim(),
          tipo: TipoDocumento.daEstensione(estensione),
          parentId: parentId,
          ultimaModifica: DateTime.now(),
          dimensioni: file.dimensione,
          percorsoFile: percorso,
        );
      });

  @override
  Future<void> rinomina(Documento documento, String nome) => eseguiSupabase(() async {
        await supabase.from(_table).update({
          'titolo': nome.trim(),
          'ultima_modifica': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', documento.id);
        notifyListeners();
      });

  @override
  Future<void> elimina(ArchivioDocumenti archivio, Documento documento) =>
      eseguiSupabase(() async {
        // I file da togliere dallo storage: quello del documento e, per una
        // cartella, quelli di tutto il suo contenuto.
        var daTogliere = [documento];
        if (documento.isCartella) {
          final List<dynamic> rows = await _righe(await _proprietario(archivio));
          final tutti = rows.map((r) => _fromDb(r as Map<String, dynamic>));
          daTogliere = discendenti(tutti, documento.id);
        }
        final percorsi = [
          for (final d in daTogliere)
            if (d.percorsoFile case final String percorso) percorso,
        ];

        // Prima le righe (il contenuto di una cartella va a cascata), poi i
        // file: se lo storage fallisce restano file orfani, privati e
        // invisibili, mai righe che puntano a file inesistenti.
        await supabase.from(_table).delete().eq('id', documento.id);
        notifyListeners();
        try {
          await _storage.elimina(bucketDocumenti, percorsi);
        } catch (e) {
          debugPrint('File orfani dopo l\'eliminazione di ${documento.id}: $e');
        }
      });

  @override
  Future<String> urlFile(Documento documento) {
    final percorso = documento.percorsoFile;
    if (percorso == null) {
      throw const JambException(
        TipoErrore.datiNonValidi,
        'Questo documento non ha un file da aprire.',
      );
    }
    return _storage.urlFirmato(bucketDocumenti, percorso);
  }

  Map<String, dynamic> _colonneProprietario(
    ({String sezione, String? unitId, String groupId}) p,
  ) =>
      {'sezione': p.sezione, 'unit_id': p.unitId, 'group_id': p.groupId};

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
      percorsoFile: isCartella ? null : row['file_url'] as String?,
      ultimaModifica: _parseDate(row['ultima_modifica']) ??
          _parseDate(row['data_caricamento']) ??
          DateTime.now(),
    );
  }

  /// Converte una data del DB in [DateTime] locale (null se assente/non valida).
  DateTime? _parseDate(dynamic v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toLocal() : null;
}
