import 'package:flutter/material.dart';

class AlertMediciWidget extends StatelessWidget {
  final int schedeInScadenza;
  final VoidCallback onVediTap;

  const AlertMediciWidget({
    super.key,
    required this.schedeInScadenza,
    required this.onVediTap,
  });

  @override
  Widget build(BuildContext context) {
    // Se non ci sono schede in scadenza, il widget si auto-distrugge e non occupa spazio!
    if (schedeInScadenza <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFCF5EB), // Sfondo crema chiaro
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Striscia laterale arancione solida
            Container(
              width: 5,
              color: const Color(0xFFE96A25), // Arancione scuro
            ),
            
            // Blocco Icona
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E5D4), // Arancione sbiadito per lo sfondo dell'icona
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE96A25),
                  size: 24,
                ),
              ),
            ),
            
            // Blocco Testi Centrale
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ALERT MEDICI/PRIVACY",
                      style: TextStyle(
                        color: Color(0xFFE96A25),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$schedeInScadenza Schede mediche in scadenza questa settimana.",
                      style: const TextStyle(
                        color: Color(0xFF374151), // Grigio/Blu scuro
                        fontSize: 12,
                        height: 1.3,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Pulsante "VEDI"
            GestureDetector(
              onTap: onVediTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 2), // Distanza della sottolineatura
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE96A25),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: const Text(
                      "VEDI",
                      style: TextStyle(
                        color: Color(0xFFE96A25),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
