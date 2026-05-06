import 'package:flutter/material.dart';

/// Card informativa per visualizzare lo stato di completamento globale di una categoria di documenti.
/// Mostra un'icona, il titolo della categoria, il conteggio numerico e una mini barra di progresso.
class StatusDocumentoCard extends StatelessWidget {
  /// Titolo della categoria (es. "Censimenti")
  final String titolo;
  /// Icona identificativa
  final IconData icona;
  /// Numero di documenti validi/completati
  final int attuali;
  /// Numero totale di ragazzi
  final int totali;
  /// Callback opzionale al tocco della card
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
    // Calcolo della percentuale di completamento per la barra di progresso
    final double progresso = totali > 0 ? attuali / totali : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- HEADER: ICONA E TITOLO ---
            Row(
              children: [
                Icon(icona, color: const Color(0xFF1D2660), size: 18),
                const SizedBox(width: 10),
                Text(
                  titolo,
                  style: const TextStyle(
                    color: Color(0xFF64748B), // Slate 500
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // --- FOOTER: CONTEGGIO E PROGRESSO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rappresentazione testuale (es. "24/28")
                Text(
                  "$attuali/$totali",
                  style: const TextStyle(
                    color: Color(0xFF0F172A), // Slate 900
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
                // Rappresentazione visuale (Barra di progresso compatta)
                SizedBox(
                  width: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progresso,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1D2660)),
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
