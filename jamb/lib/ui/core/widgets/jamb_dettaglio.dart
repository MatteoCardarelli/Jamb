import 'package:flutter/material.dart';

/// Titolo principale delle schermate di dettaglio (es. evento, avviso).
class JambTitoloDettaglio extends StatelessWidget {
  final String testo;

  const JambTitoloDettaglio(this.testo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      testo,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1E293B),
        fontFamily: 'Lexend',
      ),
    );
  }
}

/// Riga con icona e testo nelle schermate di dettaglio (es. orario, luogo).
class JambRigaDettaglio extends StatelessWidget {
  final IconData icona;
  final String testo;

  const JambRigaDettaglio({super.key, required this.icona, required this.testo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icona, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              testo,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF334155),
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
