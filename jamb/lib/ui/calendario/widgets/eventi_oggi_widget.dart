import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/calendario_view_model.dart';
import '../../../domain/entities/evento.dart';
import 'package:jamb/core/categoria_evento_colori.dart'; 

/// Elenco degli eventi del giorno selezionato nel calendario.
class EventiOggiWidget extends StatelessWidget {
  const EventiOggiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarioViewModel>();
    final isToday = DateUtils.isSameDay(viewModel.selectedDate, DateTime.now());
    
    // Format the date like "Giovedì 5 Ott"
    final dateStr = DateFormat('EEEE d MMM', 'it_IT').format(viewModel.selectedDate);
    // Capitalize first letter
    final formattedDate = "${dateStr[0].toUpperCase()}${dateStr.substring(1)}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isToday ? "Eventi di oggi" : "Eventi",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B), // Dark text
                ),
              ),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B), // Slate text
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (viewModel.eventiDelGiorno.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Nessun evento in questa data.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.eventiDelGiorno.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _EventoCard(evento: viewModel.eventiDelGiorno[index]);
              },
            ),
        ],
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Evento evento;

  const _EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final timeStr = "${timeFormat.format(evento.dataInizio)} - ${timeFormat.format(evento.dataFine)}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left colored stripe
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: evento.colorePrincipale,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time and More vert icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: evento.colorePrincipale,
                          ),
                        ),
                        const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Title
                    Text(
                      evento.titolo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          evento.luogo,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Categories
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: evento.categorie.map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: sfondoCategoria(cat),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: coloreCategoria(cat),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
