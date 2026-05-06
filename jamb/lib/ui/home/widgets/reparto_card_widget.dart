import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Card informativa che mostra il nome del reparto e le statistiche degli iscritti.
/// Utilizza un design "Dark" con colori istituzionali e il logo AGESCI come sfondo decorativo.
class RepartoCardWidget extends StatelessWidget {
  const RepartoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      height: 130, // Altezza fissa per coerenza col design
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A42), // Blu notte profondo del brand
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Assicura che la filigrana non esca dai bordi stondati
      child: Stack(
        children: [
          // FILIGRANA DECORATIVA
          // Logo AGESCI ingrandito, decentrato e semitrasparente
          Positioned(
            right: -60,
            top: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.15,
              child: SvgPicture.asset(
                'assets/icons/logo_agesci.svg',
                height: 200,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          
          // CONTENUTO TESTUALE
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "REPARTO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                        height: 1.0, // Interlinea stretta per effetto tipografico compatto
                      ),
                    ),
                    Text(
                      "VELINO",
                      style: TextStyle(
                        color: Color(0xFFFFC500), // Giallo Agesci istituzionale
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                Text(
                  "32 GUIDE ED ESPLORATORI ATTIVI",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
