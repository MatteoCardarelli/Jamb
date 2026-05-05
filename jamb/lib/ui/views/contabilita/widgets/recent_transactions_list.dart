import 'package:flutter/material.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intestazione
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Transazioni recenti",
              style: TextStyle(
                color: Color(0xFF000066),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "VEDI TUTTE",
                style: TextStyle(
                  color: Color(0xFF000066),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista Transazioni
        _buildTransactionItem(
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF1B5E20),
          bgColor: const Color(0xFFE8F5E9),
          title: "Quota Uscita San Giorgio",
          subtitle: "Oggi, 14:30 • Entrata",
          amount: "+ € 240,00",
          amountColor: const Color(0xFF1B5E20),
        ),
        _buildTransactionItem(
          icon: Icons.shopping_cart_outlined,
          iconColor: const Color(0xFFB91C1C),
          bgColor: const Color(0xFFFEF2F2),
          title: "Spesa Alimentare Reparto",
          subtitle: "Ieri, 18:15 • Uscita",
          amount: "- € 84,20",
          amountColor: const Color(0xFFB91C1C),
        ),
        _buildTransactionItem(
          icon: Icons.build_outlined,
          iconColor: const Color(0xFFB91C1C),
          bgColor: const Color(0xFFFEF2F2),
          title: "Materiale Pioneristica",
          subtitle: "12 Mag • Uscita",
          amount: "- € 36,10",
          amountColor: const Color(0xFFB91C1C),
        ),
        _buildTransactionItem(
          icon: Icons.savings_outlined,
          iconColor: const Color(0xFFB91C1C),
          bgColor: const Color(0xFFFEF2F2),
          title: "Rimborso Carburante Capo",
          subtitle: "10 Mag • Entrata",
          amount: "- € 25,00",
          amountColor: const Color(0xFFB91C1C),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Icona con sfondo circolare
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          
          // Testi Centrali
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
          
          // Importo
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: amountColor,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}
