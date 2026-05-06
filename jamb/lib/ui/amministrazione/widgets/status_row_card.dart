import 'package:flutter/material.dart';
import '../../../../domain/entities/scout.dart';

/// Riga interattiva per la tabella amministrativa dei ragazzi.
/// Visualizza l'avatar (iniziali), il nome dello scout e tre indicatori di stato cliccabili
/// per Censimento, Privacy e Scheda Medica.
class StatusRowCard extends StatelessWidget {
  /// L'entità Scout che contiene tutti i dati
  final Scout ragazzo;
  
  /// Callback per il cambio stato del censimento
  final VoidCallback? onCensimentoTap;
  /// Callback per il cambio stato della privacy
  final VoidCallback? onPrivacyTap;
  /// Callback per il cambio stato della scheda medica
  final VoidCallback? onMedicaTap;

  const StatusRowCard({
    super.key,
    required this.ragazzo,
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
              ragazzo.iniziali,
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
              ragazzo.nome,
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
              child: Center(child: _buildStatusIcon(ragazzo.statoCensimento)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onPrivacyTap, 
              child: Center(child: _buildStatusIcon(ragazzo.statoPrivacy)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onMedicaTap, 
              child: Center(child: _buildStatusIcon(ragazzo.statoMedica)),
            ),
          ),
        ],
      ),
    );
  }

  /// Restituisce l'icona appropriata in base allo stato del documento
  Widget _buildStatusIcon(DocumentoStatus status) {
    switch (status) {
      case DocumentoStatus.nessuno:
        return const Icon(Icons.circle_outlined, color: Color(0xFFE2E8F0), size: 22);
      case DocumentoStatus.valido:
        return const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 22);
      case DocumentoStatus.inScadenza:
        return const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 22);
      case DocumentoStatus.scaduto:
        return const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 22);
    }
  }
}
