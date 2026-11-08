import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';

/// Messaggio mostrato al posto dei dati quando il caricamento fallisce,
/// con un pulsante per riprovare.
class JambStatoErrore extends StatelessWidget {
  final String messaggio;
  final VoidCallback onRiprova;

  const JambStatoErrore({
    super.key,
    required this.messaggio,
    required this.onRiprova,
  });

  @override
  Widget build(BuildContext context) {
    // Stesso aspetto di uno stato vuoto centrato, più il tasto «Riprova».
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        JambTestoVuoto(
          "Impossibile caricare i dati",
          icona: Icons.cloud_off_rounded,
          suggerimento: messaggio,
          centrato: true,
        ),
        TextButton.icon(
          onPressed: onRiprova,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text("Riprova"),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1D2660)),
        ),
      ],
    );
  }
}
