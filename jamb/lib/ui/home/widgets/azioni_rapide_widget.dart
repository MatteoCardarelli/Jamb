import 'package:flutter/material.dart';
import 'package:jamb/ui/calendario/widgets/form_evento_screen.dart';
import 'package:jamb/ui/contabilita/widgets/add_transaction_screen.dart';
import 'package:jamb/ui/core/stile.dart';

/// Griglia di pulsanti rapidi per le azioni comuni (Crea Avviso, Nuovo Evento, ecc.).
/// Visualizzata sotto gli avvisi amministrativi nella HomeView.
///
/// Le azioni non ancora realizzate sono attenuate e lo dicono quando vengono
/// toccate: un pulsante visibile non deve sembrare funzionante se non lo è.
class AzioniRapideWidget extends StatelessWidget {
  const AzioniRapideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Distanziamento flessibile dalla sezione precedente
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Azioni Rapide",
            style: TextStyle(
              color: Color(0xFF0B192C),
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lexend',
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Griglia fissa di pulsanti d'azione
          GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 2, // 2 colonne
            shrinkWrap: true, // Necessario per l'uso dentro un SingleChildScrollView
            physics: const NeverScrollableScrollPhysics(), // La griglia non deve scorrere autonomamente
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7, // Rende i bottoni rettangolari per un look più moderno
            children: [
              _buildAzioneCard(
                context,
                icon: Icons.campaign_outlined,
                label: "Crea Avviso",
              ),
              _buildAzioneCard(
                context,
                icon: Icons.calendar_month_outlined,
                label: "Nuovo Evento",
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FormEventoScreen()),
                ),
              ),
              _buildAzioneCard(
                context,
                icon: Icons.receipt_long_outlined,
                label: "Nuova Transazione",
                onTap: () => AddTransactionScreen.apri(context),
              ),
              _buildAzioneCard(
                context,
                icon: Icons.upload_file_outlined,
                label: "Carica Doc",
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Costruisce una singola card d'azione; senza [onTap] l'azione non è
  /// ancora disponibile e viene mostrata attenuata.
  Widget _buildAzioneCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final disponibile = onTap != null;
    final colore = disponibile ? const Color(0xFF1D2660) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap ??
          () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$label sarà disponibile in una prossima versione.")),
              ),
      child: Container(
        decoration: BoxDecoration(
          color: disponibile ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: bordoRiquadro,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colore,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: colore,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
