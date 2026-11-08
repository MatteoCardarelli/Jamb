import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Data breve per gli elenchi: l'ora se è di oggi, altrimenti giorno e mese
/// (con l'anno se diverso da quello corrente). Usata da bacheca e documenti.
String dataBreve(DateTime data, {DateTime? adesso}) {
  final oggi = adesso ?? DateTime.now();
  if (DateUtils.isSameDay(data, oggi)) return DateFormat('HH:mm').format(data);
  final formato = data.year == oggi.year ? 'd MMM' : 'd MMM y';
  return DateFormat(formato, 'it_IT').format(data);
}

/// Importo in [centesimi] alla maniera italiana, senza valuta: "1.234,50".
String importoLeggibile(int centesimi) =>
    NumberFormat('#,##0.00', 'it_IT').format(centesimi / 100);

/// Dimensione di un file in forma leggibile, es. "820 KB", "2,4 MB".
String dimensioneLeggibile(int byte) {
  if (byte < 1024) return '$byte B';
  if (byte < 1024 * 1024) return '${(byte / 1024).round()} KB';
  final mb = byte / (1024 * 1024);
  return '${mb.toStringAsFixed(1).replaceAll('.', ',')} MB';
}
