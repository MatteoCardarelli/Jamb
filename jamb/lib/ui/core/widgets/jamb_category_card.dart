import 'package:flutter/material.dart';

/// Card di navigazione visuale utilizzata per rappresentare categorie, cartelle o sezioni.
/// Supporta opzionalmente una barra di progresso per indicare lo stato di completamento.
class JambCategoryCard extends StatelessWidget {
  /// Titolo principale della card
  final String titolo;
  /// Sottotitolo descrittivo
  final String sottotitolo;
  /// Icona identificativa
  final IconData icona;
  /// Livello di progresso opzionale (da 0.0 a 1.0)
  final double? progresso;
  /// Testo descrittivo del progresso (es. "3/10")
  final String? progressoTesto;
  /// Callback invocata al tocco della card
  final VoidCallback? onTap;

  const JambCategoryCard({
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9).withOpacity(0.5), // Sfondo slate semitrasparente
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuisce lo spazio
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICONA
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D2660),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icona, color: Colors.white, size: 16),
                ),
                const SizedBox(height: 10),
                
                // TITOLO
                Text(
                  titolo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Lexend',
                    height: 1.1,
                  ),
                ),
                
                // SOTTOTITOLO
                if (sottotitolo.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    sottotitolo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            
            // BARRA DI PROGRESSO (Sempre in fondo se presente)
            if (progresso != null) 
              Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progresso,
                            minHeight: 6, // Leggermente più spessa
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1D2660)),
                          ),
                        ),
                      ),
                      if (progressoTesto != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          progressoTesto!,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 10,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
