import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/views/verifica_obiettivi/widgets/score_selector.dart';

/// Card che visualizza i dettagli di un singolo obiettivo scout.
/// Include l'icona tematica, il grado di raggiungimento (ScoreSelector) e il Diario di Bordo.
class ObiettivoCard extends StatelessWidget {
  /// L'entità obiettivo da visualizzare
  final Obiettivo obiettivo;
  /// Callback invocata quando cambia il punteggio (grado)
  final ValueChanged<int> onScoreChanged;
  /// Callback invocata quando si preme l'icona di modifica
  final VoidCallback onEditTap;
  /// Callback invocata quando si preme l'icona di eliminazione
  final VoidCallback onDeleteTap;

  const ObiettivoCard({
    super.key,
    required this.obiettivo,
    required this.onScoreChanged,
    required this.onEditTap,
    required this.onDeleteTap,
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
          // --- HEADER: ICONA, TITOLO E TASTO MODIFICA ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icona con sfondo colorato semitrasparente coordinato
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
              
              // Testi: Dominio e Descrizione
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
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
                        // Tasti di azione (Modifica ed Elimina)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onEditTap,
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Color(0xFF1D2660),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: onDeleteTap,
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFEF4444), // Rosso per l'eliminazione
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      obiettivo.descrizione,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // --- SEZIONE PUNTEGGIO ---
          const Text(
            "GRADO DI RAGGIUNGIMENTO",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 12),
          
          // Widget per la selezione del punteggio (1-5)
          ScoreSelector(
            selectedScore: obiettivo.grado,
            onScoreChanged: onScoreChanged,
          ),
          
          const SizedBox(height: 24),
          
          // --- SEZIONE DIARIO DI BORDO ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
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
                        fontFamily: 'Lexend',
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
                    fontFamily: 'Lexend',
                    height: 1.4,
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
