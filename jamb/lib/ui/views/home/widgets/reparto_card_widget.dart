import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RepartoCardWidget extends StatelessWidget {
  const RepartoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Forza la card a prendere tutta la larghezza disponibile
      margin: const EdgeInsets.only(top: 24),
      height: 130, // Altezza fissa calcolata in proporzione al design
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A42), // Blu notte profondo
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Taglia la grafica che sborda
      child: Stack(
        children: [
          // Grafica di sfondo decorativa sulla destra
          // Ho usato il logo AGESCI ingrandito e decentrato per simulare i due alberi di sfondo!
          Positioned(
            right: -60,
            top: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.15, // Leggera trasparenza per fare l'effetto "filigrana"
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
          
          // Contenuto Testuale
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spinge titolo in alto e sottotitolo in basso
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
                        height: 1.0, // Interlinea strettissima come da design
                      ),
                    ),
                    Text(
                      "VELINO",
                      style: TextStyle(
                        color: Color(0xFFFFC500), // Giallo Agesci
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
                    color: Colors.white.withOpacity(0.7), // Grigio/Bianco sporco
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2, // Spaziatura larga tra le lettere
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
