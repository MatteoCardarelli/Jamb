import 'package:flutter/material.dart';

/// Pulsante a tutta larghezza per un'azione secondaria dentro un riquadro
/// (es. «Aggiungi specialità», «Fai l'appello»): sfondo chiaro, bordo
/// sottile, icona e testo blu.
class JambPulsanteSecondario extends StatelessWidget {
  final IconData icona;
  final String etichetta;
  final VoidCallback onTap;

  const JambPulsanteSecondario({
    super.key,
    required this.icona,
    required this.etichetta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icona, color: const Color(0xFF1D2660), size: 18),
            const SizedBox(width: 8),
            Text(
              etichetta,
              style: const TextStyle(
                color: Color(0xFF1D2660),
                fontWeight: FontWeight.w800,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
