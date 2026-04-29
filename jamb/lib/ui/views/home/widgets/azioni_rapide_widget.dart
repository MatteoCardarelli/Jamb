import 'package:flutter/material.dart';

class AzioniRapideWidget extends StatelessWidget {
  const AzioniRapideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Margin top 24 lo distanzia da qualsiasi cosa ci sia sopra. 
      // Se l'alert scompare, questo margine lo distanzierà direttamente dalla card principale!
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Azioni Rapide",
            style: TextStyle(
              color: Color(0xFF0B192C), // Blu scurissimo
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Lexend',
              letterSpacing: 0.3,
            ),
          ),
          GridView.count(
            padding: EdgeInsets.zero, // Rimuove il padding implicito invisibile della griglia
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7, // Rende i bottoni rettangolari larghi
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
            color: const Color(0xFFCBD5E1), // Bordo grigio chiaro
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF1D2660), // Blu scuro
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
