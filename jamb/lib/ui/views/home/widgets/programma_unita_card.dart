import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';

class ProgrammaUnitaCard extends StatelessWidget {
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
          // Header
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
                  ),
                ),
              ),
              Text(
                "26/04/2026",
                style: TextStyle(
                  color: darkBlue.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
            ),
          ),
          const SizedBox(height: 20),

          // Progress Bars
          ...obiettivi.map((ob) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildProgressBarRow(ob.colore, ob.grado, 5),
              )),
          
          const SizedBox(height: 12),

          // Legend
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate width for 2 columns with 16px spacing
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

  Widget _buildLegendItem(Color dotColor, String label, int score, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label: $score/5",
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

