import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/calendario/view_model/calendario_view_model.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';
import 'package:jamb/ui/calendario/widgets/calendario_widget.dart';
import 'package:jamb/ui/calendario/widgets/eventi_oggi_widget.dart';
import 'package:jamb/ui/calendario/widgets/prossimi_eventi_widget.dart';
import 'package:jamb/ui/calendario/widgets/crea_evento_screen.dart';

/// Schermata del calendario: calendario mensile, eventi del giorno e prossimi eventi.
class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarioViewModel>();

    return EmptyBackgroundScreen(
      currentIndex: 3, // Indice per il Calendario
      floatingActionButton: JambFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreaEventoScreen()),
          );
        },
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 120), // Spazio per la TopBar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CalendarioWidget(),
              ),
              // Un errore non va confuso con "nessun evento in questa data".
              if (viewModel.haErrore)
                JambStatoErrore(
                  messaggio: viewModel.errore!,
                  onRiprova: viewModel.refresh,
                )
              else ...const [
                EventiOggiWidget(),
                ProssimiEventiWidget(),
              ],
              const SizedBox(height: 80), // Padding below for the bottom navbar
            ],
          ),
        ),
      ),
    );
  }
}
