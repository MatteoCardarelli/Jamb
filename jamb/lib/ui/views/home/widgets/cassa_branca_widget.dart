import 'package:flutter/material.dart';

class CassaBrancaWidget extends StatelessWidget {
  const CassaBrancaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)), // Grigio chiarissimo per il bordino
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icona, Titolo, Freccia
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3D7), // Giallo pallido
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFF3E2D20), // Marrone scuro/grigio
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                "Cassa di Branca",
                style: TextStyle(
                  color: Color(0xFF00005C), // Blu navy scurissimo
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8), // Grigio ardesia chiaro
                size: 24,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Saldo e Budget (Row con allineamento in basso)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Blocco Saldo
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SALDO ATTUALE",
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  Text(
                    "450,00 €",
                    style: TextStyle(
                      color: Color(0xFF00005C), // Navy scurissimo
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              // Blocco Budget
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "BUDGET MENSILE",
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "60% utilizzato",
                    style: TextStyle(
                      color: const Color(0xFF1E293B), // Slate scuro
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 4), // Piccolo offset per allineare alla baseline del saldo
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Barra di Progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 6,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)), // Giallo Ambra
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Divisore
          const Divider(
            color: Color(0xFFF1F5F9),
            height: 1,
            thickness: 1,
          ),
          
          const SizedBox(height: 20),
          
          // Transazioni Ricenti
          _buildTransaction(
            isPositive: true,
            title: "Quota S. Giorgio",
            amount: "+150,00 €",
          ),
          const SizedBox(height: 16),
          _buildTransaction(
            isPositive: false,
            title: "Materiale Pionerismo",
            amount: "-36,10 €",
          ),
        ],
      ),
    );
  }

  Widget _buildTransaction({required bool isPositive, required String title, required String amount}) {
    return Row(
      children: [
        // Cerchietto + o -
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isPositive ? const Color(0xFFEAF5EB) : const Color(0xFFFCE9EA), // Verde pallidissimo / Rosso pallidissimo
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPositive ? Icons.add : Icons.remove,
            color: isPositive ? const Color(0xFF1B703C) : const Color(0xFFC8202F), // Verde deciso / Rosso deciso
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        // Nome Transazione
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lexend',
          ),
        ),
        const Spacer(),
        // Importo Transazione
        Text(
          amount,
          style: TextStyle(
            color: isPositive ? const Color(0xFF1B703C) : const Color(0xFFC8202F),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
