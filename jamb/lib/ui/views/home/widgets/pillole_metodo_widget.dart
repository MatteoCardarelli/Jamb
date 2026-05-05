import 'package:flutter/material.dart';

/// Widget decorativo che mostra citazioni o pillole metodologiche scout.
/// Caratterizzato da uno sfondo verde foresta e un layout con icone in filigrana.
class PilloleMetodoWidget extends StatelessWidget {
  const PilloleMetodoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF325D32), // Verde foresta profondo (Metodo Scout)
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, 
      child: Stack(
        children: [
          // FILIGRANA DECORATIVA
          // Icona che richiama l'apprendimento e lo studio del metodo
          Positioned(
            right: -20,
            bottom: -30,
            child: Opacity(
              opacity: 0.15,
              child: const Icon(
                Icons.local_library_outlined, 
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
          
          // CONTENUTO PRINCIPALE
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intestazione con icona lampadina (Insight/Idea)
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFFFFC500),
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
                
                // Testo della citazione/consiglio
                Text(
                  "\"L'importanza del Consiglio della Legge: Non è solo un momento di verifica, ma il cuore della democrazia in Squadriglia.\"",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w300, // Peso leggero per distinguere la citazione dal titolo
                    height: 1.6, // Interlinea aumentata per favorire la lettura
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
