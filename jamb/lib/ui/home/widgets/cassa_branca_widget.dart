import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';
import 'package:intl/intl.dart';

/// Widget riassuntivo della situazione finanziaria del reparto.
/// Mostra il saldo attuale, l'utilizzo del budget mensile e le ultime due transazioni.
class CassaBrancaWidget extends StatelessWidget {
  const CassaBrancaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Ascolta i cambiamenti della contabilità
    final financeProvider = context.watch<ContabilitaViewModel>();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
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
          // INTESTAZIONE: Titolo e icona portafoglio
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3D7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFF3E2D20),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                "Cassa di Branca",
                style: TextStyle(
                  color: Color(0xFF00005C),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // AREA DATI: Saldo e Budget
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Visualizzazione Saldo Attuale (Dinamico)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
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
                    currencyFormat.format(financeProvider.saldoAttuale),
                    style: const TextStyle(
                      color: Color(0xFF00005C),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              // Info Budget Mensile (Dinamico)
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
                    "${(financeProvider.budgetPercentage * 100).toInt()}% utilizzato",
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // BARRA DI PROGRESSO BUDGET (Dinamica)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: financeProvider.budgetPercentage,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          const SizedBox(height: 20),
          
          // LISTA TRANSAZIONI RECENTI (Ultime 2 dal Provider)
          ...financeProvider.transactions.take(2).map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTransaction(
              isPositive: t.isPositive,
              title: t.title,
              amount: "${t.isPositive ? '+' : '-'}${currencyFormat.format(t.amount)}",
            ),
          )),
        ],
      ),
    );
  }

  /// Costruisce una riga di transazione con colori semantici (Verde/Rosso)
  Widget _buildTransaction({required bool isPositive, required String title, required String amount}) {
    // Definizione dei colori in base al tipo di transazione (Entrata/Uscita)
    final Color color = isPositive ? const Color(0xFF1B703C) : const Color(0xFFC8202F);
    final Color bgColor = isPositive ? const Color(0xFFEAF5EB) : const Color(0xFFFCE9EA);

    return Row(
      children: [
        // Icona indicatrice (+/-) in cerchio colorato
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPositive ? Icons.add : Icons.remove,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        // Titolo operazione
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
        // Valore monetario evidenziato
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
