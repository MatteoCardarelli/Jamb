import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/sottogruppi/widgets/sottogruppi_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/ragazzi/widgets/ragazzo_card.dart';
import 'package:jamb/ui/ragazzi/widgets/ragazzi_filters.dart';
import 'package:jamb/ui/ragazzi/view_model/ragazzi_view_model.dart';

/// Schermata principale per la gestione e visualizzazione dell'elenco ragazzi.
/// Include funzionalità di ricerca testuale, filtraggio per squadriglia e avvisi medici.
class RagazziScreen extends StatelessWidget {
  const RagazziScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usiamo watch per far ricostruire la schermata quando cambia lo stato
    final viewModel = context.watch<RagazziViewModel>();
    final risultati = viewModel.ragazziFiltrati;

    return EmptyBackgroundScreen(
      currentIndex: 1, // Icona ragazzi selezionata nella BottomBar
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              // Padding top di 170 per lasciare spazio alla TopBar flottante
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BARRA DI RICERCA CENTRALIZZATA
                  JambSearchBar(
                    controller: viewModel.searchController,
                    hintText: "Cerca scout o squadriglia...",
                  ),
                  const SizedBox(height: 16),

                  // SEZIONE FILTRI
                  RagazziFilters(
                    squadrigliaSelezionata: viewModel.squadrigliaFiltro,
                    alertMediciAttivo: viewModel.alertFiltro,
                    squadriglie: viewModel.squadriglie,
                    onSquadrigliaChanged: viewModel.setSquadrigliaFiltro,
                    onAlertChanged: viewModel.setAlertFiltro,
                  ),
                  const SizedBox(height: 16),

                  // SOTTOGRUPPI, per le branche che ne hanno
                  if (!SottogruppiBranca.di(context.read<SessionService>().tipoBrancaAttiva).vuota) ...[
                    JambPulsanteSecondario(
                      icona: Icons.groups_outlined,
                      etichetta: "Sottogruppi",
                      onTap: () => SottogruppiScreen.apri(context),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // LISTA RISULTATI
                  if (viewModel.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(color: Color(0xFF1D2660)),
                      ),
                    )
                  else if (viewModel.haErrore)
                    JambStatoErrore(
                      messaggio: viewModel.errore!,
                      onRiprova: viewModel.refresh,
                    )
                  else if (risultati.isEmpty)
                    const JambTestoVuoto(
                      "Nessun ragazzo trovato",
                      icona: Icons.search_off_rounded,
                      suggerimento: "Prova a cambiare i filtri o la ricerca",
                      centrato: true,
                    )
                  else
                    ...risultati.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RagazzoCard(scout: r),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
