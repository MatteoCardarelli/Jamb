import 'package:flutter/material.dart';

class StatoAmministrativoWidget extends StatelessWidget {
  const StatoAmministrativoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Un gradiente elegante per richiamare il verde scuro dell'immagine
        gradient: const LinearGradient(
          colors: [Color(0xFF28562A), Color(0xFF132D15)], // Verde scuro verso verde scurissimo
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intestazione con icona
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                "Stato Amministrativo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Cerchi statistici (usando Row e Expanded per non farli stringere)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCircle(
                value: 28,
                total: 32,
                label: "CENSIMENTI",
              ),
              _buildStatCircle(
                value: 24,
                total: 32,
                label: "SCHEDE MEDICHE",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCircle({
    required int value,
    required int total,
    required String label,
  }) {
    final double progress = value / total;
    
    return Column(
      children: [
        SizedBox(
          width: 105, // Dimensione per far entrare perfettamente i due cerchi
          height: 105,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Sfondo del cerchio (Verde semi-trasparente)
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 7,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.15)),
              ),
              // Progresso effettivo
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 7,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF91E68C)), // Verde brillante
              ),
              // Testo centrale (Numero Grande e Totale Piccolo)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    Text(
                      " /$total",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Etichetta CENSIMENTI / SCHEDE MEDICHE e freccia
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 9,
            ),
          ],
        ),
      ],
    );
  }
}
