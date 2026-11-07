import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/documento.dart';

/// Icona e colori con cui mostrare un tipo di documento, usati nel Drive e
/// nei documenti recenti.
extension TipoDocumentoUi on TipoDocumento {
  IconData get icona => switch (this) {
        TipoDocumento.cartella => Icons.folder_rounded,
        TipoDocumento.pdf => Icons.picture_as_pdf_rounded,
        TipoDocumento.jpeg || TipoDocumento.png => Icons.image_rounded,
        TipoDocumento.xls => Icons.table_chart_rounded,
        TipoDocumento.ppt => Icons.slideshow_rounded,
        TipoDocumento.zip => Icons.folder_zip_rounded,
        TipoDocumento.doc || TipoDocumento.txt => Icons.description_rounded,
      };

  /// Colore dell'icona.
  Color get colore => switch (this) {
        TipoDocumento.pdf => const Color(0xFFE11D48),
        TipoDocumento.jpeg || TipoDocumento.png => const Color(0xFF16A34A),
        TipoDocumento.xls => const Color(0xFF15803D),
        TipoDocumento.ppt => const Color(0xFFEA580C),
        _ => const Color(0xFF0284C7),
      };

  /// Sfondo chiaro dietro l'icona.
  Color get sfondo => colore.withValues(alpha: 0.12);
}
