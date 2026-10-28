import 'package:flutter/material.dart';

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Impossibile caricare i dati",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              messaggio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRiprova,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Riprova"),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1D2660)),
            ),
          ],
        ),
      ),
    );
  }
}
