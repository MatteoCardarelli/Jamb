import 'package:flutter/material.dart';

class AllergieWidget extends StatelessWidget {
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
        color: const Color(0xFFFDE2E2), // Sfondo rosso chiarissimo
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.medical_services, color: Color(0xFFB91C1C), size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "URGENT",
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Allergie",
            style: TextStyle(
              color: Color(0xFFB91C1C),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            allergie,
            style: const TextStyle(
              color: Color(0xFF7F1D1D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}
