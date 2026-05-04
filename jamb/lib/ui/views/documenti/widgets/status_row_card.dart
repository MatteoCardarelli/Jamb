import 'package:flutter/material.dart';

enum DocumentStatus { none, valid, expiring, missing }

class StatusRowCard extends StatelessWidget {
  final String initials;
  final String nome;
  final DocumentStatus censimento;
  final DocumentStatus privacy;
  final DocumentStatus medica;
  final VoidCallback? onCensimentoTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onMedicaTap;

  const StatusRowCard({
    super.key,
    required this.initials,
    required this.nome,
    required this.censimento,
    required this.privacy,
    required this.medica,
    this.onCensimentoTap,
    this.onPrivacyTap,
    this.onMedicaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nome
          Expanded(
            flex: 3,
            child: Text(
              nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          // Icone Status (Cliccabili e centrate)
          Expanded(child: GestureDetector(onTap: onCensimentoTap, child: Center(child: _buildStatusIcon(censimento)))),
          Expanded(child: GestureDetector(onTap: onPrivacyTap, child: Center(child: _buildStatusIcon(privacy)))),
          Expanded(child: GestureDetector(onTap: onMedicaTap, child: Center(child: _buildStatusIcon(medica)))),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.none:
        return const Icon(Icons.circle_outlined, color: Color(0xFFE2E8F0), size: 22);
      case DocumentStatus.valid:
        return const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF22C55E), size: 22);
      case DocumentStatus.expiring:
        return const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 22);
      case DocumentStatus.missing:
        return const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 22);
    }
  }
}
