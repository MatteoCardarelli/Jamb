import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/calendario/view_model/calendario_view_model.dart';
import 'package:jamb/ui/campo/widgets/campi_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';
import 'package:jamb/ui/calendario/widgets/calendario_widget.dart';
import 'package:jamb/ui/calendario/widgets/eventi_oggi_widget.dart';
import 'package:jamb/ui/calendario/widgets/prossimi_eventi_widget.dart';
import 'package:jamb/ui/calendario/widgets/form_evento_screen.dart';

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
          // Il nuovo evento parte dal giorno selezionato nel calendario.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormEventoScreen(giorno: viewModel.selectedDate),
            ),
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
                _FiltriCalendario(),
                EventiOggiWidget(),
                ProssimiEventiWidget(),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: JambPulsanteSecondario(
                  icona: Icons.park_outlined,
                  etichetta: "Campi e uscite",
                  onTap: () => CampiScreen.apri(context),
                ),
              ),
              const SizedBox(height: 80), // Padding below for the bottom navbar
            ],
          ),
        ),
      ),
    );
  }
}

/// Scelta di quali eventi mostrare: tutti, della mia unità o della Co.Ca.
class _FiltriCalendario extends StatelessWidget {
  const _FiltriCalendario();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarioViewModel>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final filtro in viewModel.filtri)
              JambChipFiltro(
                etichetta: filtro.etichetta,
                selezionato: viewModel.filtro == filtro,
                onTap: () => viewModel.setFiltro(filtro),
              ),
          ],
        ),
      ),
    );
  }
}
