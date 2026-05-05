import 'package:flutter/material.dart';

/// Card informativa per visualizzare lo stato dei consensi privacy dello scout.
/// Indica chiaramente la data di scadenza dei moduli firmati per garantire la conformità legale.
class PrivacyWidget extends StatelessWidget {
  /// Data di scadenza dei consensi (es. "09/24")
  final String scadenza;

  const PrivacyWidget({
    super.key,
    required this.scadenza,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICONA: Navy Blue
          const Icon(
            Icons.assignment_turned_in_rounded, 
            color: Color(0xFF1D2660), 
            size: 24
          ),
          const SizedBox(height: 16),
          
          // TITOLO SEZIONE
          const Text(
            "Privacy",
            style: TextStyle(
              color: Color(0xFF1D2660),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lexend',
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          
          // CONTENUTO TESTUALE
          Text(
            "Validità fino a $scadenza",
            style: const TextStyle(
              color: Color(0xFF64748B), // Slate 500
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}
