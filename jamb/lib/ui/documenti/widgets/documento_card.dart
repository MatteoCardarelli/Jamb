import 'package:flutter/material.dart';

enum DocumentStatus { valido, inScadenza, mancante }

/// Card che rappresenta un documento o una cartella nell'elenco documenti.
class DocumentoCard extends StatelessWidget {
  final String titolo;
  final String ragazzo;
  final DateTime? scadenza;
  final DocumentStatus status;
  final VoidCallback? onTap;

  const DocumentoCard({
    super.key,
    required this.titolo,
    required this.ragazzo,
    this.scadenza,
    required this.status,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case DocumentStatus.valido:
        return const Color(0xFF16A34A); // Success
      case DocumentStatus.inScadenza:
        return const Color(0xFFEA580C); // Warning
      case DocumentStatus.mancante:
        return const Color(0xFFE11D48); // Danger
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case DocumentStatus.valido:
        return "VALIDO";
      case DocumentStatus.inScadenza:
        return "IN SCADENZA";
      case DocumentStatus.mancante:
        return "MANCANTE";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icona Documento
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_rounded,
                color: _getStatusColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titolo,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ragazzo,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  if (scadenza != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Scade il ${scadenza!.day}/${scadenza!.month}/${scadenza!.year}",
                      style: TextStyle(
                        color: status == DocumentStatus.inScadenza 
                            ? const Color(0xFFEA580C) 
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Badge Stato
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getStatusLabel(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Lexend',
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
