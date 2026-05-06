import 'package:flutter/material.dart';

/// Widget di avviso amministrativo che compare nella Home.
/// Utilizza una palette di colori arancio/crema per segnalare criticità (es. documenti scaduti).
class AlertMediciWidget extends StatelessWidget {
  /// Il testo descrittivo dell'allerta (es. "3 schede mediche scadute")
  final String messaggio;
  /// Callback eseguita al tocco del pulsante "VEDI"
  final VoidCallback onVediTap;

  const AlertMediciWidget({
    super.key,
    required this.messaggio,
    required this.onVediTap,
  });

  @override
  Widget build(BuildContext context) {
    // Se non ci sono messaggi, il widget scompare completamente
    if (messaggio.isEmpty) return const SizedBox.shrink();

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
            // Barretta laterale arancione per enfasi visiva
            Container(
              width: 5,
              color: const Color(0xFFE96A25),
            ),
            
            // Icona di avviso in un box stondato
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E5D4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE96A25),
                  size: 24,
                ),
              ),
            ),
            
            // Area Testuale (Titolo + Messaggio dinamico)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ALERT AMMINISTRAZIONE",
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
                      messaggio,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 12,
                        height: 1.3,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Pulsante di azione "VEDI" con sottolineatura personalizzata
            GestureDetector(
              onTap: onVediTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 2), 
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
