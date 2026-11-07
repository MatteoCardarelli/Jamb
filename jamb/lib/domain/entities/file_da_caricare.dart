import 'dart:typed_data';

/// File scelto sul dispositivo e non ancora archiviato (es. la foto di uno
/// scontrino o un documento per il Drive).
class FileDaCaricare {
  /// Nome originale, da cui si ricava l'estensione.
  final String nome;
  final Uint8List byte;

  const FileDaCaricare({required this.nome, required this.byte});

  int get dimensione => byte.length;
}
