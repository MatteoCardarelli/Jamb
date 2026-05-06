import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';
import 'package:intl/intl.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<ContabilitaViewModel>();
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

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

        // Lista Transazioni dal Provider
        ...financeProvider.transactions.map((t) => _buildTransactionItem(
          icon: t.isPositive ? Icons.add_circle_outline_rounded : Icons.shopping_cart_outlined,
          iconColor: t.isPositive ? const Color(0xFF1B5E20) : const Color(0xFFB91C1C),
          bgColor: t.isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFEF2F2),
          title: t.title,
          subtitle: "${dateFormat.format(t.date)} • ${t.isPositive ? 'Entrata' : 'Uscita'}",
          amount: "${t.isPositive ? '+' : '-'} € ${t.amount.toStringAsFixed(2).replaceAll('.', ',')}",
          amountColor: t.isPositive ? const Color(0xFF1B5E20) : const Color(0xFFB91C1C),
        )),
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
