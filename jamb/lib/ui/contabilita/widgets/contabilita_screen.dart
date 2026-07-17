import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/contabilita/widgets/add_transaction_screen.dart';
import 'package:jamb/ui/contabilita/view_model/add_transaction_view_model.dart';
import 'package:jamb/ui/contabilita/widgets/balance_card.dart';
import 'package:jamb/ui/contabilita/widgets/expenses_distribution_card.dart';
import 'package:jamb/ui/contabilita/widgets/recent_transactions_list.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';

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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final transazione = await Navigator.of(context).push<Transazione>(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider(
                create: (_) => AddTransactionViewModel(),
                child: const AddTransactionScreen(),
              ),
              transitionDuration: Duration.zero,
            ));

            if (transazione != null) {
              financeViewModel.addTransaction(transazione);
            }
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
              BalanceCard(saldo: financeViewModel.saldoAttuale),

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
