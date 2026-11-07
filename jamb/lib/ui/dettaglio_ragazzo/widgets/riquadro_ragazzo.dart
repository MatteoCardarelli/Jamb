import 'package:flutter/material.dart';

/// Riquadro bianco delle sezioni del dettaglio ragazzo (contatti, Sentiero,
/// specialità, brevetti, presenze), con il [titolo] della sezione se presente.
class RiquadroRagazzo extends StatelessWidget {
  final String? titolo;
  final List<Widget> children;

  const RiquadroRagazzo({super.key, this.titolo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titolo != null) ...[
            Text(
              titolo!,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// Testo di una sezione del dettaglio ragazzo senza dati (es. nessun brevetto).
class RiquadroRagazzoVuoto extends StatelessWidget {
  final String testo;

  const RiquadroRagazzoVuoto(this.testo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        testo,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontFamily: 'Lexend',
          fontSize: 14,
        ),
      ),
    );
  }
}
