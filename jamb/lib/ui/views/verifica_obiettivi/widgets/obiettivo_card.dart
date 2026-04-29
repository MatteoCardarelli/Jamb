import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/views/verifica_obiettivi/widgets/score_selector.dart';

class ObiettivoCard extends StatelessWidget {
  final Obiettivo obiettivo;
  final ValueChanged<int> onScoreChanged;
  final VoidCallback onEditTap;

  const ObiettivoCard({
    super.key,
    required this.obiettivo,
    required this.onScoreChanged,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Icon + Title + Edit + Description)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with light background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: obiettivo.colore.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  obiettivo.icona,
                  color: obiettivo.colore,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            obiettivo.dominio.toUpperCase(),
                            style: TextStyle(
                              color: obiettivo.colore,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onEditTap,
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF1D2660),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      obiettivo.descrizione,
                      style: const TextStyle(
                        color: Color(0xFF1F2937), // Dark grey
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            "GRADO DI RAGGIUNGIMENTO",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Score Selector
          ScoreSelector(
            selectedScore: obiettivo.grado,
            onScoreChanged: onScoreChanged,
          ),
          
          const SizedBox(height: 24),
          
          // Diario di Bordo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9), // Light grey
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book, // Assuming a book icon for Diario
                      color: Color(0xFF1D2660),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Diario di bordo",
                      style: TextStyle(
                        color: Color(0xFF1D2660),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  obiettivo.diarioDiBordo.isEmpty 
                    ? "Inserisci un testo..." 
                    : obiettivo.diarioDiBordo,
                  style: TextStyle(
                    color: obiettivo.diarioDiBordo.isEmpty 
                      ? Colors.grey 
                      : const Color(0xFF4B5563),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
