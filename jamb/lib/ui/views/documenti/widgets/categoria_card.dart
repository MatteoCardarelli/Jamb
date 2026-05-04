import 'package:flutter/material.dart';

class CategoriaCard extends StatelessWidget {
  final String titolo;
  final String sottotitolo;
  final IconData icona;
  final double? progresso; // Da 0.0 a 1.0
  final String? progressoTesto;
  final VoidCallback? onTap;

  const CategoriaCard({
    super.key,
    required this.titolo,
    required this.sottotitolo,
    required this.icona,
    this.progresso,
    this.progressoTesto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icona con contenitore blu
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icona,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(height: 8),
            // Titolo
            Text(
              titolo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFamily: 'Lexend',
              ),
            ),
            if (sottotitolo.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                sottotitolo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            // Barra di progresso (opzionale)
            if (progresso != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 3,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E293B)),
                      ),
                    ),
                  ),
                  if (progressoTesto != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      progressoTesto!,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 8,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
