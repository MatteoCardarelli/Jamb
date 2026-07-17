import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/ui/contabilita/view_model/dettaglio_transazione_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Schermata di dettaglio di una singola transazione, con opzione di eliminazione.
class DettaglioTransazioneScreen extends StatelessWidget {
  const DettaglioTransazioneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DettaglioTransazioneViewModel>();
    final transazione = viewModel.transazione;

    final currencyFormat = NumberFormat.currency(locale: 'it_IT', symbol: '€');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Dettaglio Operazione",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontFamily: 'Lexend'),
        ),
        centerTitle: true,
        actions: [
          // TASTO ELIMINA
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB91C1C)),
            onPressed: () => _showDeleteConfirmation(context, viewModel),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "${transazione.isUscita ? '-' : '+'} ${currencyFormat.format(transazione.importo)}",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: viewModel.colorePrincipale,
                      fontFamily: 'Lexend',
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: viewModel.coloreSfondo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          transazione.isUscita ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                          size: 14,
                          color: viewModel.colorePrincipale,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          viewModel.tipoMovimento,
                          style: TextStyle(
                            color: viewModel.colorePrincipale,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.0,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: "DATA OPERAZIONE",
                    value: dateFormat.format(transazione.data),
                    trailing: timeFormat.format(transazione.data),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    icon: Icons.build_outlined,
                    label: "CATEGORIA",
                    value: _getLabelForCategory(transazione.categoria),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    icon: Icons.description_outlined,
                    label: "CAUSALE / NOTE",
                    value: transazione.note.isNotEmpty ? transazione.note : "Nessuna nota",
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    icon: Icons.person_outline_rounded,
                    label: "REGISTRATO DA",
                    value: transazione.registratoDa,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.receipt_long_rounded, color: Color(0xFF000066)),
                      SizedBox(width: 12),
                      Text(
                        "Foto dello Scontrino",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF94A3B8),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DettaglioTransazioneViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Elimina transazione"),
        content: const Text("Sei sicuro di voler eliminare questa transazione? L'azione non è reversibile."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("ANNULLA", style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () async {
              await viewModel.elimina();
              if (context.mounted) {
                Navigator.of(context).pop(); // Chiude il dialog
                Navigator.of(context).pop(); // Torna alla lista
              }
            },
            child: const Text("ELIMINA", style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF000066), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                  if (trailing != null)
                    Text(
                      trailing,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        fontFamily: 'Lexend',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLabelForCategory(Categoria cat) {
    switch (cat) {
      case Categoria.attivita: return "Attività";
      case Categoria.materiale: return "Attrezzatura di Reparto";
      case Categoria.trasporto: return "Trasporto";
      case Categoria.sede: return "Sede";
      case Categoria.quote: return "Quote";
      case Categoria.altro: return "Altro";
    }
  }
}
