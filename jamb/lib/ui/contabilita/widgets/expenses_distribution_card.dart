import 'package:flutter/material.dart';
import 'dart:math';

class ExpensesDistributionCard extends StatelessWidget {
  const ExpensesDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Dati mock per ora
    final List<Map<String, dynamic>> dati = [
      {"label": "Attività", "valore": 0.45, "colore": const Color(0xFF000066)},
      {"label": "Materiale", "valore": 0.30, "colore": const Color(0xFF1B5E20)},
      {"label": "Sede", "valore": 0.15, "colore": const Color(0xFFFFC107)},
      {"label": "Altro", "valore": 0.10, "colore": const Color(0xFFE2E8F0)},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo con Icona
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF000066), width: 2),
                ),
                child: const Icon(Icons.pie_chart_outline_rounded, size: 18, color: Color(0xFF000066)),
              ),
              const SizedBox(width: 12),
              const Text(
                "Ripartizione Spese",
                style: TextStyle(
                  color: Color(0xFF000066),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              // Grafico a Ciambella
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: DonutChartPainter(dati: dati),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "USCITE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            fontFamily: 'Lexend',
                          ),
                        ),
                        Text(
                          "€ 840",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF000066),
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              
              // Legenda
              Expanded(
                child: Column(
                  children: dati.map((item) => _buildLegendItem(item)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: item['colore'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item['label'],
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E293B),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "${(item['valore'] * 100).toInt()}%",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> dati;

  DonutChartPainter({required this.dati});

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -pi / 2;
    final double strokeWidth = 14;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    for (var item in dati) {
      final sweepAngle = item['valore'] * 2 * pi;
      final paint = Paint()
        ..color = item['colore']
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
