import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
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
                  const SizedBox(height: 24),

                  // LISTA RISULTATI
                  if (viewModel.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(color: Color(0xFF1D2660)),
                      ),
                    )
                  else if (risultati.isEmpty)
                    _buildEmpty()
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

  /// Messaggio visualizzato quando la ricerca non produce risultati
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Nessun ragazzo trovato",
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Prova a cambiare i filtri o la ricerca",
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
