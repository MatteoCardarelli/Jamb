import 'dart:typed_data';

import 'package:jamb/data/services/storage_service.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';

/// Archivio dei file finto (in memoria) per i test.
///
/// [file] contiene i file caricati per `bucket/percorso`; [erroreCaricamento]
/// ed [erroreEliminazione], se impostati, vengono sollevati dalle operazioni
/// corrispondenti.
class FakeStorageService implements IStorageService {
  final Map<String, Uint8List> file = {};
  final List<String> eliminati = [];
  JambException? erroreCaricamento;
  JambException? erroreEliminazione;

  @override
  Future<void> carica(String bucket, String percorso, Uint8List byte, String mime) async {
    if (erroreCaricamento != null) throw erroreCaricamento!;
    file['$bucket/$percorso'] = byte;
  }

  @override
  Future<String> urlFirmato(String bucket, String percorso) async =>
      'https://archivio.test/$bucket/$percorso';

  @override
  Future<void> elimina(String bucket, List<String> percorsi) async {
    if (erroreEliminazione != null) throw erroreEliminazione!;
    for (final p in percorsi) {
      file.remove('$bucket/$p');
      eliminati.add('$bucket/$p');
    }
  }
}
