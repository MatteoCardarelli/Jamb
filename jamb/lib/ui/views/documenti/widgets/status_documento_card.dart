import 'package:flutter/material.dart';

class StatusDocumentoCard extends StatelessWidget {
  final String titolo;
  final IconData icona;
  final int attuali;
  final int totali;
  final VoidCallback? onTap;

  const StatusDocumentoCard({
    super.key,
    required this.titolo,
    required this.icona,
    required this.attuali,
    required this.totali,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progresso = totali > 0 ? attuali / totali : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Riga superiore: Icona + Titolo
            Row(
              children: [
                Icon(icona, color: const Color(0xFF25315B), size: 16),
                const SizedBox(width: 8),
                Text(
                  titolo,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Riga inferiore: Numero + Barra
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Numero grande
                Text(
                  "$attuali/$totali",
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
                // Barra di progresso
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progresso,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF25315B)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
