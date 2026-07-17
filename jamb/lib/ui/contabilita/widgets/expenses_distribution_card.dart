import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'dart:math';

/// Card con la distribuzione delle uscite per categoria.
class ExpensesDistributionCard extends StatelessWidget {
  const ExpensesDistributionCard({super.key});

  Color _getColorForCategory(Categoria cat) {
    switch (cat) {
      case Categoria.attivita: return const Color(0xFF000066);
      case Categoria.materiale: return const Color(0xFF1B5E20);
      case Categoria.trasporto: return const Color(0xFFE96A25);
      case Categoria.sede: return const Color(0xFFFFC107);
      case Categoria.quote: return const Color(0xFF6366F1);
      case Categoria.altro: return const Color(0xFF94A3B8);
    }
  }

  String _getLabelForCategory(Categoria cat) {
    switch (cat) {
      case Categoria.attivita: return "Attività";
      case Categoria.materiale: return "Materiale";
      case Categoria.trasporto: return "Trasporto";
      case Categoria.sede: return "Sede";
      case Categoria.quote: return "Quote";
      case Categoria.altro: return "Altro";
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ContabilitaViewModel>();
    final ripartizione = viewModel.ripartizioneSpese;
    final totaleUscite = viewModel.totaleUscite;

    // Se non ci sono uscite, mostriamo un messaggio informativo
    if (ripartizione.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: const Center(
          child: Text(
            "Nessuna uscita registrata per visualizzare la ripartizione.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Lexend'),
          ),
        ),
      );
    }

    // Convertiamo la mappa in una lista di dati per il painter e la legenda
    final List<Map<String, dynamic>> dati = ripartizione.entries.map((e) {
      return {
        "label": _getLabelForCategory(e.key),
        "valore": e.value,
        "colore": _getColorForCategory(e.key),
      };
    }).toList();

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
              // Grafico a Ciambella Dinamico
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
                      children: [
                        const Text(
                          "USCITE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            fontFamily: 'Lexend',
                          ),
                        ),
                        Text(
                          "€ ${totaleUscite.toInt()}",
                          style: const TextStyle(
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
              
              // Legenda Dinamica
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
    const double strokeWidth = 14;
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
