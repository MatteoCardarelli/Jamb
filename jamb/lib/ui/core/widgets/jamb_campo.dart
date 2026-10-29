import 'package:flutter/material.dart';

/// Etichetta in maiuscolo sopra un campo dei form (es. «TITOLO EVENTO»).
class JambEtichettaCampo extends StatelessWidget {
  final String testo;

  const JambEtichettaCampo(this.testo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        testo.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Aspetto dei campi di testo dei form: sfondo chiaro, bordo sottile che
/// diventa blu quando il campo ha il focus, [icona] facoltativa a sinistra.
InputDecoration jambDecorazioneCampo(String suggerimento, {IconData? icona}) {
  OutlineInputBorder bordo(Color colore, {double spessore = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colore, width: spessore),
      );

  return InputDecoration(
    hintText: suggerimento,
    prefixIcon: icona != null
        ? Icon(icona, color: const Color(0xFF94A3B8))
        : null,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: bordo(const Color(0xFFE2E8F0)),
    enabledBorder: bordo(const Color(0xFFE2E8F0)),
    focusedBorder: bordo(const Color(0xFF1D2660), spessore: 2),
  );
}
