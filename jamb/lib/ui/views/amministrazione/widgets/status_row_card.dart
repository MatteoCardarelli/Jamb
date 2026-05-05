import 'package:flutter/material.dart';

/// Stati possibili per un documento amministrativo
enum DocumentStatus { none, valid, expiring, missing }

/// Riga interattiva per la tabella amministrativa dei ragazzi.
/// Visualizza l'avatar (iniziali), il nome dello scout e tre indicatori di stato cliccabili
/// per Censimento, Privacy e Scheda Medica.
class StatusRowCard extends StatelessWidget {
  /// Iniziali del ragazzo per l'avatar
  final String initials;
  /// Nome completo dello scout
  final String nome;
  /// Stato del censimento
  final DocumentStatus censimento;
  /// Stato della privacy
  final DocumentStatus privacy;
  /// Stato della scheda medica
  final DocumentStatus medica;
  
  /// Callback per il cambio stato del censimento
  final VoidCallback? onCensimentoTap;
  /// Callback per il cambio stato della privacy
  final VoidCallback? onPrivacyTap;
  /// Callback per il cambio stato della scheda medica
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
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // AVATAR: Cerchio grigio con iniziali
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF475569), // Slate 600
                fontSize: 12,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // NOME RAGAZZO
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
          
          // INDICATORI DI STATO (Cliccabili e centrate nelle rispettive colonne)
          Expanded(
            child: GestureDetector(
              onTap: onCensimentoTap, 
              child: Center(child: _buildStatusIcon(censimento)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onPrivacyTap, 
              child: Center(child: _buildStatusIcon(privacy)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onMedicaTap, 
              child: Center(child: _buildStatusIcon(medica)),
            ),
          ),
        ],
      ),
    );
  }

  /// Restituisce l'icona appropriata in base allo stato del documento
  Widget _buildStatusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.none:
        return const Icon(Icons.circle_outlined, color: Color(0xFFE2E8F0), size: 22);
      case DocumentStatus.valid:
        return const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 22);
      case DocumentStatus.expiring:
        return const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 22);
      case DocumentStatus.missing:
        return const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 22);
    }
  }
}
