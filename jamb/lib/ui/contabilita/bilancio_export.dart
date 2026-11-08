import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:jamb/domain/entities/bilancio.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/pdf_jamb.dart';

/// Bilancio dell'unità in PDF (US26): riepilogo per categoria e movimenti
/// dell'anno. Gli importi non hanno il simbolo «€», che il font base non ha.
Future<Uint8List> generaBilancioPdf({
  required String unita,
  required Bilancio bilancio,
  required DateTime data,
}) {
  pw.Widget riga(String etichetta, int centesimi, {bool forte = false}) {
    final stile = pw.TextStyle(
      fontSize: 11,
      fontWeight: forte ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(etichetta, style: stile), pw.Text(importoLeggibile(centesimi), style: stile)],
      ),
    );
  }

  pw.Widget titolo(String testo) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 4),
        child: pw.Text(testo,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: bluPdf)),
      );

  return generaPdfJamb(
    titolo: 'Bilancio ${bilancio.annoScout}',
    sottotitolo: '$unita · Importi in euro · ${DateFormat('dd/MM/yyyy').format(data)}',
    autore: unita,
    contenuto: [
      riga('Saldo iniziale', bilancio.saldoIniziale, forte: true),
      titolo('Entrate'),
      for (final c in Categoria.values)
        if (bilancio.entrate[c] case final importo?) riga(c.etichetta, importo),
      riga('Totale entrate', bilancio.totaleEntrate, forte: true),
      titolo('Uscite'),
      for (final c in Categoria.values)
        if (bilancio.uscite[c] case final importo?) riga(c.etichetta, importo),
      riga('Totale uscite', bilancio.totaleUscite, forte: true),
      pw.Divider(color: grigioPdf),
      riga('Saldo finale', bilancio.saldoFinale, forte: true),
      titolo('Movimenti'),
      if (bilancio.movimenti.isEmpty)
        pw.Text("Nessun movimento nell'anno.", style: const pw.TextStyle(color: grigioPdf))
      else
        pw.TableHelper.fromTextArray(
          headers: const ['Data', 'Descrizione', 'Categoria', 'Entrata', 'Uscita'],
          data: [for (final t in bilancio.movimenti) _colonneMovimento(t).map(testoPerPdf).toList()],
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: bluPdf),
          headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
          cellStyle: const pw.TextStyle(fontSize: 9),
          border: const pw.TableBorder(
            horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
          ),
          columnWidths: const {
            0: pw.FixedColumnWidth(58),
            1: pw.FlexColumnWidth(),
            2: pw.FixedColumnWidth(62),
            3: pw.FixedColumnWidth(58),
            4: pw.FixedColumnWidth(58),
          },
          cellAlignments: const {3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight},
        ),
    ],
  );
}

/// Data, descrizione, categoria, entrata e uscita di un movimento.
List<String> _colonneMovimento(Transazione t) {
  final importo = importoLeggibile(centesimiDi(t.importo));
  return [
    DateFormat('dd/MM/yyyy').format(t.data),
    t.titolo,
    t.categoria.etichetta,
    t.isUscita ? '' : importo,
    t.isUscita ? importo : '',
  ];
}

/// Bilancio dell'unità in CSV, nel formato che Excel apre correttamente in
/// italiano: separatore «;», virgola decimale, UTF-8 con BOM.
Uint8List generaBilancioCsv({required String unita, required Bilancio bilancio}) {
  List<String> riepilogo(String voce, int centesimi) => [voce, '', '', importoLeggibile(centesimi)];

  final righe = <List<String>>[
    ['Bilancio ${bilancio.annoScout}', unita],
    [],
    ['Voce', 'Tipo', 'Categoria', 'Importo'],
    riepilogo('Saldo iniziale', bilancio.saldoIniziale),
    for (final c in Categoria.values)
      if (bilancio.entrate[c] case final importo?)
        ['Entrata', 'Entrata', c.etichetta, importoLeggibile(importo)],
    riepilogo('Totale entrate', bilancio.totaleEntrate),
    for (final c in Categoria.values)
      if (bilancio.uscite[c] case final importo?)
        ['Uscita', 'Uscita', c.etichetta, importoLeggibile(importo)],
    riepilogo('Totale uscite', bilancio.totaleUscite),
    riepilogo('Saldo finale', bilancio.saldoFinale),
    [],
    ['Data', 'Descrizione', 'Categoria', 'Entrata', 'Uscita'],
    for (final t in bilancio.movimenti) _colonneMovimento(t),
  ];
  final testo = righe.map((r) => r.map(campoCsv).join(';')).join('\r\n');
  return Uint8List.fromList(utf8.encode('﻿$testo\r\n'));
}

/// Campo di un CSV: tra virgolette se contiene separatori o a capo. Un testo
/// che inizia come una formula (=, +, -, @) riceve un apostrofo davanti,
/// altrimenti un foglio di calcolo lo eseguirebbe. Gli importi negativi
/// restano numeri.
String campoCsv(String campo) {
  final numero = RegExp(r'^-?[\d.]+,\d{2}$').hasMatch(campo);
  final sicuro = !numero && RegExp(r'^[=+\-@\t\r]').hasMatch(campo) ? "'$campo" : campo;
  if (!RegExp(r'[;"\r\n]').hasMatch(sicuro)) return sicuro;
  return '"${sicuro.replaceAll('"', '""')}"';
}
