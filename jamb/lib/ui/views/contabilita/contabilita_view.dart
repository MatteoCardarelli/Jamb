import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/views/add_transaction/add_transaction_view.dart';
import 'package:jamb/ui/views/contabilita/widgets/balance_card.dart';
import 'package:jamb/ui/views/contabilita/widgets/expenses_distribution_card.dart';
import 'package:jamb/ui/views/contabilita/widgets/recent_transactions_list.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/providers/contabilita_provider.dart';

class ContabilitaView extends StatelessWidget {
  const ContabilitaView({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<ContabilitaProvider>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 2,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const AddTransactionView(),
              transitionDuration: Duration.zero,
            ));
          },
          backgroundColor: const Color(0xFF000066),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con tasto back
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF25315B)),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Contabilità",
                    style: TextStyle(
                      color: Color(0xFF25315B),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // IL WIDGET SALDO (Dati dal Provider)
              BalanceCard(saldo: financeProvider.saldoAttuale),

              const SizedBox(height: 16),

              // IL WIDGET RIPARTIZIONE SPESE
              const ExpensesDistributionCard(),

              const SizedBox(height: 32),

              // LA LISTA TRANSAZIONI RECENTI (Nuovo)
              const RecentTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }
}
