import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';

/// Regole sui file archiviati: bucket, percorsi, tipi ammessi e limiti.
/// Devono restare allineate alla migrazione `archiviazione_documenti`
/// (un test confronta i tipi MIME).

const String bucketDocumenti = 'documenti';
const String bucketRicevute = 'ricevute';

/// Secondo livello del percorso dei file di libreria (Metodo e Statuto,
/// Modulistica), al posto dell'unità.
const String cartellaLibreria = 'libreria';

/// Dimensione massima di un documento (come `file_size_limit` del bucket).
const int limiteDocumenti = 20 * 1024 * 1024;

/// Dimensione massima di una ricevuta.
const int limiteRicevute = 10 * 1024 * 1024;

/// Tipi MIME dei documenti, per estensione.
const Map<String, String> mimeDocumenti = {
  'pdf': 'application/pdf',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
  'heic': 'image/heic',
  'txt': 'text/plain',
  'csv': 'text/csv',
  'doc': 'application/msword',
  'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'xls': 'application/vnd.ms-excel',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'ppt': 'application/vnd.ms-powerpoint',
  'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'odt': 'application/vnd.oasis.opendocument.text',
  'ods': 'application/vnd.oasis.opendocument.spreadsheet',
  'odp': 'application/vnd.oasis.opendocument.presentation',
  'zip': 'application/zip',
};

/// Tipi MIME delle ricevute (foto o PDF), per estensione.
const Map<String, String> mimeRicevute = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
  'heic': 'image/heic',
  'pdf': 'application/pdf',
};

/// Estensione di [nomeFile] in minuscolo, senza punto ('' se non c'è).
String estensioneDi(String nomeFile) {
  final punto = nomeFile.lastIndexOf('.');
  if (punto <= 0 || punto == nomeFile.length - 1) return '';
  return nomeFile.substring(punto + 1).toLowerCase();
}

/// Identificativo casuale nel formato UUID v4, per il nome dei file archiviati.
String idCasuale([Random? casuale]) {
  final r = casuale ?? Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40; // versione 4
  b[8] = (b[8] & 0x3f) | 0x80; // variante RFC 4122
  final hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Percorso di un file: `{gruppo}/{cartella}/{id}.{estensione}`, dove
/// [cartella] è l'unità o [cartellaLibreria]. Il nome originale non entra nel
/// percorso: resta solo nel database, così non serve ripulirlo.
String percorsoFile({
  required String gruppo,
  required String cartella,
  required String id,
  required String estensione,
}) =>
    '$gruppo/$cartella/$id${estensione.isEmpty ? '' : '.$estensione'}';

/// Tipo MIME ammesso per [nomeFile] tra quelli di [ammessi]; solleva una
/// [JambException] se il tipo non è ammesso o il file supera [limite] byte.
String verificaFile(
  String nomeFile,
  int dimensione, {
  required Map<String, String> ammessi,
  required int limite,
}) {
  final mime = ammessi[estensioneDi(nomeFile)];
  if (mime == null) {
    throw const JambException(
      TipoErrore.datiNonValidi,
      'Tipo di file non supportato.',
    );
  }
  if (dimensione > limite) {
    throw JambException(
      TipoErrore.datiNonValidi,
      'Il file supera i ${limite ~/ (1024 * 1024)} MB.',
    );
  }
  return mime;
}

/// Carica un file e poi scrive la riga che lo descrive. Se la scrittura
/// fallisce, il file appena caricato viene eliminato (compensazione), così
/// non restano file senza riga; l'errore originale arriva comunque al
/// chiamante. Se fallisce anche l'eliminazione, il file resta orfano: è
/// invisibile e non espone dati, perché lo storage è privato.
Future<T> caricaConCompensazione<T>({
  required Future<void> Function() caricaFile,
  required Future<T> Function() scriviRiga,
  required Future<void> Function() eliminaFile,
}) async {
  await caricaFile();
  try {
    return await scriviRiga();
  } catch (_) {
    try {
      await eliminaFile();
    } catch (e) {
      debugPrint('File orfano dopo un salvataggio fallito: $e');
    }
    rethrow;
  }
}
