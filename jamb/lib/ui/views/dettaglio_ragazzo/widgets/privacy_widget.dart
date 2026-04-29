import 'package:flutter/material.dart';

class PrivacyWidget extends StatelessWidget {
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
          const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF00005C), size: 24),
          const SizedBox(height: 16),
          const Text(
            "Privacy",
            style: TextStyle(
              color: Color(0xFF00005C),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Consensi validi fino a $scadenza",
            style: const TextStyle(
              color: Color(0xFF64748B),
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
