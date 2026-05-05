import 'package:flutter/material.dart';

/// Card informativa per visualizzare le allergie critiche dello scout.
/// Utilizza una palette cromatica rossa (Alert) per attirare l'attenzione
/// su informazioni mediche potenzialmente vitali.
class AllergieWidget extends StatelessWidget {
  /// Lista o descrizione delle allergie (es. "Arachidi, Penicillina")
  final String allergie;

  const AllergieWidget({
    super.key,
    required this.allergie,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE2E2), // Red 100
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFECACA)), // Red 200
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB91C1C).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICONA E BADGE "URGENT"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.medical_services_rounded, color: Color(0xFFB91C1C), size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "URGENT",
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // TITOLO SEZIONE
          const Text(
            "Allergie",
            style: TextStyle(
              color: Color(0xFFB91C1C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lexend',
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          
          // CONTENUTO TESTUALE
          Text(
            allergie,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF7F1D1D), // Red 900
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}
