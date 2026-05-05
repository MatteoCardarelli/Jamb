import 'package:flutter/material.dart';

/// Griglia di pulsanti rapidi per le azioni comuni (Crea Avviso, Nuovo Evento, ecc.).
/// Visualizzata sotto gli avvisi amministrativi nella HomeView.
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
                icon: Icons.campaign_outlined,
                label: "Crea Avviso",
                onTap: () {},
              ),
              _buildAzioneCard(
                icon: Icons.calendar_month_outlined,
                label: "Nuovo Evento",
                onTap: () {},
              ),
              _buildAzioneCard(
                icon: Icons.military_tech_outlined,
                label: "Assegna Punti SQ",
                onTap: () {},
              ),
              _buildAzioneCard(
                icon: Icons.upload_file_outlined,
                label: "Carica Doc",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Costruisce una singola card d'azione cliccabile
  Widget _buildAzioneCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF1D2660),
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1D2660),
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
