import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/core/pdf_jamb.dart';

/// Programma d'Unità in PDF (US17): intestazione con unità, anno scout e
/// data, poi per ogni obiettivo dominio, descrizione, grado di
/// raggiungimento e diario di bordo.
Future<Uint8List> generaProgrammaPdf({
  required String unita,
  required String annoScout,
  required List<Obiettivo> obiettivi,
  required DateTime data,
}) {
  return generaPdfJamb(
    titolo: "Programma d'Unità",
    sottotitolo: '$unita · Anno scout $annoScout · ${DateFormat('dd/MM/yyyy').format(data)}',
    autore: unita,
    contenuto: [
      if (obiettivi.isEmpty)
        pw.Text('Nessun obiettivo nel Programma.', style: const pw.TextStyle(color: grigioPdf)),
      for (final o in obiettivi)
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: PdfColor.fromInt(o.colore.toARGB32()), width: 4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(testoPerPdf(o.dominio.toUpperCase()),
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: grigioPdf)),
              pw.SizedBox(height: 4),
              pw.Text(testoPerPdf(o.descrizione), style: const pw.TextStyle(fontSize: 13)),
              pw.SizedBox(height: 6),
              pw.Text('Grado di raggiungimento: ${o.grado} su 5',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: bluPdf)),
              if (o.diarioDiBordo.trim().isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Text('Diario di bordo', style: const pw.TextStyle(fontSize: 10, color: grigioPdf)),
                pw.Text(testoPerPdf(o.diarioDiBordo), style: const pw.TextStyle(fontSize: 11)),
              ],
            ],
          ),
        ),
    ],
  );
}
