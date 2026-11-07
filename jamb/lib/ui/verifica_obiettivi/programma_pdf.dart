import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:jamb/domain/entities/obiettivo.dart';

/// Testo scritto sul telefono adattato al font base del PDF: apostrofi,
/// virgolette e trattini tipografici (inseriti in automatico da molte
/// tastiere) diventano quelli semplici, altrimenti sparirebbero. Emoji e
/// simboli fuori dal font restano esclusi dal PDF, senza errori.
String testoPerPdf(String testo) => testo
    .replaceAll(RegExp('[‘’‚′]'), "'")
    .replaceAll(RegExp('[“”„″]'), '"')
    .replaceAll(RegExp('[–—]'), '-')
    .replaceAll('…', '...');

/// Programma d'Unità in PDF (US17): intestazione con unità, anno scout e
/// data, poi per ogni obiettivo dominio, descrizione, grado di
/// raggiungimento e diario di bordo.
Future<Uint8List> generaProgrammaPdf({
  required String unita,
  required String annoScout,
  required List<Obiettivo> obiettivi,
  required DateTime data,
}) {
  final documento = pw.Document(
    title: "Programma d'Unità $annoScout",
    author: testoPerPdf(unita),
  );
  const blu = PdfColor.fromInt(0xFF1D2660);
  const grigio = PdfColor.fromInt(0xFF64748B);

  documento.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    header: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Programma d'Unità",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: blu)),
        pw.SizedBox(height: 4),
        pw.Text(testoPerPdf('$unita · Anno scout $annoScout · ${DateFormat('dd/MM/yyyy').format(data)}'),
            style: const pw.TextStyle(fontSize: 11, color: grigio)),
        pw.Divider(color: grigio),
      ],
    ),
    footer: (context) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('Pagina ${context.pageNumber} di ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: grigio)),
    ),
    build: (_) => [
      if (obiettivi.isEmpty)
        pw.Text('Nessun obiettivo nel Programma.', style: const pw.TextStyle(color: grigio)),
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
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: grigio)),
              pw.SizedBox(height: 4),
              pw.Text(testoPerPdf(o.descrizione), style: const pw.TextStyle(fontSize: 13)),
              pw.SizedBox(height: 6),
              pw.Text('Grado di raggiungimento: ${o.grado} su 5',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: blu)),
              if (o.diarioDiBordo.trim().isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Text('Diario di bordo', style: const pw.TextStyle(fontSize: 10, color: grigio)),
                pw.Text(testoPerPdf(o.diarioDiBordo), style: const pw.TextStyle(fontSize: 11)),
              ],
            ],
          ),
        ),
    ],
  ));
  return documento.save();
}
