import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/calendario_view_model.dart';
import '../../../domain/entities/evento.dart';

class ProssimiEventiWidget extends StatelessWidget {
  const ProssimiEventiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarioViewModel>();
    final prossimiEventi = viewModel.prossimiEventi;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Prossimi Eventi",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (prossimiEventi.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Nessun evento nelle prossime 2 settimane.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(12),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prossimiEventi.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 24),
                itemBuilder: (context, index) {
                  return _ProssimoEventoRow(evento: prossimiEventi[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ProssimoEventoRow extends StatelessWidget {
  final Evento evento;

  const _ProssimoEventoRow({required this.evento});

  @override
  Widget build(BuildContext context) {
    final dayOfWeekFormat = DateFormat('EEE', 'it_IT');
    final dayOfWeekStr = dayOfWeekFormat.format(evento.dataInizio).toUpperCase();
    final dayNum = evento.dataInizio.day.toString();
    
    // Calculate duration in days (approximate for the subtitle)
    final durationDays = evento.dataFine.difference(evento.dataInizio).inDays;
    final durationStr = durationDays > 0 ? " • ${durationDays + 1} Giorni" : "";

    return Row(
      children: [
        // Date square
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayOfWeekStr,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF25315B),
                ),
              ),
              Text(
                dayNum,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                evento.titolo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${evento.luogo}$durationStr",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        
        // Right arrow
        const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      ],
    );
  }
}
