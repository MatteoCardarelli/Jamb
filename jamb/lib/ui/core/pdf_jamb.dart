import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Colori dei documenti PDF generati dall'app.
const PdfColor bluPdf = PdfColor.fromInt(0xFF1D2660);
const PdfColor grigioPdf = PdfColor.fromInt(0xFF64748B);

/// Testo scritto sul telefono adattato al font base del PDF: apostrofi,
/// virgolette e trattini tipografici (inseriti in automatico da molte
/// tastiere) diventano quelli semplici, altrimenti sparirebbero. Emoji e
/// simboli fuori dal font (anche «€») restano esclusi dal PDF, senza errori.
String testoPerPdf(String testo) => testo
    .replaceAll(RegExp('[‘’‚′]'), "'")
    .replaceAll(RegExp('[“”„″]'), '"')
    .replaceAll(RegExp('[–—]'), '-')
    .replaceAll('…', '...');

/// Documento A4 con l'impaginazione comune dell'app: in ogni pagina
/// [titolo], [sottotitolo] e il numero di pagina; il corpo è [contenuto].
Future<Uint8List> generaPdfJamb({
  required String titolo,
  required String sottotitolo,
  required String autore,
  required List<pw.Widget> contenuto,
}) {
  final documento = pw.Document(
    title: testoPerPdf(titolo),
    author: testoPerPdf(autore),
  );

  documento.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    header: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(testoPerPdf(titolo),
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: bluPdf)),
        pw.SizedBox(height: 4),
        pw.Text(testoPerPdf(sottotitolo),
            style: const pw.TextStyle(fontSize: 11, color: grigioPdf)),
        pw.Divider(color: grigioPdf),
      ],
    ),
    footer: (context) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('Pagina ${context.pageNumber} di ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: grigioPdf)),
    ),
    build: (_) => contenuto,
  ));
  return documento.save();
}
