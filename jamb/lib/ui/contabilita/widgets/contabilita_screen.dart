import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/contabilita/widgets/add_transaction_screen.dart';
import 'package:jamb/ui/contabilita/widgets/balance_card.dart';
import 'package:jamb/ui/contabilita/widgets/expenses_distribution_card.dart';
import 'package:jamb/ui/contabilita/widgets/recent_transactions_list.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';
import 'package:jamb/ui/core/widgets/jamb_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';

/// Schermata della contabilità: saldo, distribuzione delle spese ed elenco transazioni.
class ContabilitaScreen extends StatelessWidget {
  const ContabilitaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financeViewModel = context.watch<ContabilitaViewModel>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 2,
        floatingActionButton: JambFab(
          icona: Icons.add_rounded,
          backgroundColor: const Color(0xFF000066),
          onPressed: () => AddTransactionScreen.apri(context),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con tasto back
              Row(
                children: [
                  const BackActionButton(),
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

              // In caso di errore non si mostra un saldo a zero, che sarebbe falso.
              if (financeViewModel.haErrore)
                JambStatoErrore(
                  messaggio: financeViewModel.errore!,
                  onRiprova: financeViewModel.refresh,
                )
              else ...[
                // IL WIDGET SALDO (Dati dal Provider)
                BalanceCard(saldo: financeViewModel.saldoAttuale),

                const SizedBox(height: 16),

                // IL WIDGET RIPARTIZIONE SPESE
                const ExpensesDistributionCard(),

                const SizedBox(height: 32),

                // LA LISTA TRANSAZIONI RECENTI (Nuovo)
                const RecentTransactionsList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
