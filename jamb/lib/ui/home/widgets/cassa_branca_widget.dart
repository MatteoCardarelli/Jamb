import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';
import 'package:intl/intl.dart';

import 'package:jamb/ui/contabilita/widgets/dettaglio_transazione_screen.dart';
import 'package:jamb/ui/contabilita/view_model/dettaglio_transazione_view_model.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';

/// Widget riassuntivo della situazione finanziaria del reparto.
/// Mostra il saldo attuale e le ultime due transazioni in ordine cronologico.
class CassaBrancaWidget extends StatelessWidget {
  const CassaBrancaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Ascolta i cambiamenti della contabilità dal ViewModel
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
          
          // AREA SALDO ATTUALE
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
          
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          const SizedBox(height: 20),
          
          // LISTA TRANSAZIONI RECENTI (Ultime 2, già ordinate per data nel ViewModel)
          if (financeProvider.transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Nessuna transazione recente.",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontFamily: 'Lexend'),
              ),
            )
          else
            ...financeProvider.transactions.take(2).map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider(
                        create: (_) => DettaglioTransazioneViewModel(t, context.read<ITransazioneRepository>()),
                        child: const DettaglioTransazioneScreen(),
                      ),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _buildTransaction(
                  isPositive: !t.isUscita,
                  title: t.titolo,
                  amount: "${!t.isUscita ? '+' : '-'}${currencyFormat.format(t.importo)}",
                  date: DateFormat('dd MMM').format(t.data),
                ),
              ),
            )),
        ],
      ),
    );
  }

  /// Costruisce una riga di transazione con colori semantici (Verde/Rosso)
  Widget _buildTransaction({
    required bool isPositive, 
    required String title, 
    required String amount,
    required String date,
  }) {
    final Color color = isPositive ? const Color(0xFF1B703C) : const Color(0xFFC8202F);
    final Color bgColor = isPositive ? const Color(0xFFEAF5EB) : const Color(0xFFFCE9EA);

    return Row(
      children: [
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lexend',
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
