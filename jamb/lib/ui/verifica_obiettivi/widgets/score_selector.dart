import 'package:flutter/material.dart';

/// Selettore orizzontale per il grado di raggiungimento di un obiettivo (da 1 a 5).
/// Ogni punteggio è associato a un'etichetta testuale e a un colore semantico.
class ScoreSelector extends StatelessWidget {
  /// Il punteggio attualmente selezionato
  final int selectedScore;
  /// Callback invocata quando l'utente tocca un nuovo punteggio
  final ValueChanged<int> onScoreChanged;

  const ScoreSelector({
    super.key,
    required this.selectedScore,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Mappatura manuale dei punteggi per garantire etichette e colori specifici
        _buildScoreItem(1, "Non\naffron.", const Color(0xFFBCC6DB)),
        _buildScoreItem(2, "A fatica", const Color(0xFFF08E41)),
        _buildScoreItem(3, "Soddisfac.", const Color(0xFF91E68C)),
        _buildScoreItem(4, "Molto\nbene", const Color(0xFF22C55E)),
        _buildScoreItem(5, "Centrato", const Color(0xFF1D2660)),
      ],
    );
  }

  /// Costruisce un singolo pulsante di punteggio
  Widget _buildScoreItem(int score, String label, Color color) {
    final isSelected = selectedScore == score;

    return Expanded(
      child: GestureDetector(
        onTap: () => onScoreChanged(score),
        child: Container(
          height: 90, // Altezza fissa per mantenere l'allineamento orizzontale
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            // Sfondo colorato semitrasparente se selezionato, grigio altrimenti
            color: isSelected ? color.withOpacity(0.15) : const Color(0xFFF4F6F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Cerchietto con il numero del punteggio
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Etichetta descrittiva (es. "Molto bene")
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? color : const Color(0xFF6B7280),
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Lexend',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
