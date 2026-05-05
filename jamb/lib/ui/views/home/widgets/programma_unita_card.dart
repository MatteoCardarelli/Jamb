import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';

/// Card riassuntiva del Programma d'Unità visualizzata nella Home.
/// Mostra il progresso degli obiettivi (PEG) tramite barre colorate e una legenda dettagliata.
class ProgrammaUnitaCard extends StatelessWidget {
  /// Lista degli obiettivi correnti
  final List<Obiettivo> obiettivi;

  const ProgrammaUnitaCard({
    super.key,
    required this.obiettivi,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF1D2660);
    const Color textGrey = Color(0xFF7D8C9C);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // INTESTAZIONE: Titolo e Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  "Programma d'Unità",
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              Text(
                "26/04/2026",
                style: TextStyle(
                  color: darkBlue.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Allineamento Obiettivi PEG",
            style: TextStyle(
              color: textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 20),

          // BARRE DI PROGRESSO: Una per ogni obiettivo
          ...obiettivi.map((ob) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildProgressBarRow(ob.colore, ob.grado, 5),
              )),
          
          const SizedBox(height: 12),

          // LEGENDA: Griglia flessibile a 2 colonne
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: obiettivi.map((ob) {
                  return SizedBox(
                    width: itemWidth > 0 ? itemWidth : 0,
                    child: _buildLegendItem(ob.colore, ob.dominio, ob.grado, ob.colore),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Costruisce una riga di segmenti per mostrare il progresso (1-5)
  Widget _buildProgressBarRow(Color filledColor, int filledCount, int totalCount) {
    return Row(
      children: List.generate(totalCount, (index) {
        return Expanded(
          child: Container(
            height: 12,
            margin: EdgeInsets.only(right: index == totalCount - 1 ? 0 : 8),
            decoration: BoxDecoration(
              color: index < filledCount ? filledColor : const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      }),
    );
  }

  /// Costruisce un elemento della legenda con pallino colorato e testo
  Widget _buildLegendItem(Color dotColor, String label, int score, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start, // Allinea in alto se il testo va a capo
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0), // Allinea il pallino alla prima riga di testo
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label: $score/5",
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
            ),
            maxLines: 2, // Permette l'andata a capo per evitare il clipping
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
