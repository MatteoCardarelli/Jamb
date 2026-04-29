import 'package:flutter/material.dart';

class PilloleMetodoWidget extends StatelessWidget {
  const PilloleMetodoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF325D32), // Verde foresta opaco come da design
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Per evitare che l'icona di sfondo sbordi
      child: Stack(
        children: [
          // Icona decorativa in filigrana in basso a destra
          // Ho usato "local_library" perché ricorda la sagoma con la testa e il libro aperto!
          Positioned(
            right: -20,
            bottom: -30,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.local_library_outlined, 
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
          
          // Contenuto Principale
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intestazione con Lampadina
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFFFFC500), // Giallo brillante
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "PILLOLE DEL METODO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Testo della "Pillola"
                Text(
                  "\"L'importanza del Consiglio della Legge: Non è solo un momento di verifica, ma il cuore della democrazia in Squadriglia.\"",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w300, // Molto sottile per contrastare col titolo
                    height: 1.6, // Interlinea generosa
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
