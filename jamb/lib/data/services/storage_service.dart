import 'dart:typed_data';

/// Archivio dei file (documenti, ricevute), usato dai repository.
///
/// I file sono privati: non hanno un indirizzo pubblico, si aprono con un
/// URL firmato che scade dopo poco.
abstract class IStorageService {
  /// Carica [byte] in [bucket] al [percorso], con il tipo [mime].
  /// Un file già presente allo stesso percorso è un errore.
  Future<void> carica(String bucket, String percorso, Uint8List byte, String mime);

  /// URL temporaneo per aprire il file in [bucket] al [percorso].
  Future<String> urlFirmato(String bucket, String percorso);

  /// Elimina i file ai [percorsi] di [bucket]; i percorsi inesistenti sono ignorati.
  Future<void> elimina(String bucket, List<String> percorsi);
}
