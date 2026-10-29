import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/bacheca/view_model/bacheca_view_model.dart';
import 'package:jamb/ui/bacheca/widgets/avviso_card.dart';
import 'package:jamb/ui/bacheca/widgets/dettaglio_avviso_screen.dart';
import 'package:jamb/ui/bacheca/widgets/form_avviso_screen.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';
import 'package:jamb/ui/core/widgets/jamb_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_intestazione.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';

/// Bacheca avvisi dell'unità (US25), raggiunta dalla campanella della TopBar:
/// elenco dal più recente con filtro per destinatari e pulsante per scriverne uno.
class BachecaScreen extends StatelessWidget {
  const BachecaScreen({super.key});

  /// Apre la bacheca ricaricando gli avvisi, per vedere anche quelli appena
  /// pubblicati dagli altri capi.
  static Future<void> apri(BuildContext context) {
    context.read<BachecaViewModel>().ricarica();
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BachecaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BachecaViewModel>();

    return EmptyBackgroundScreen(
      currentIndex: 0,
      floatingActionButton: JambFab(
        icona: Icons.edit_rounded,
        onPressed: () => FormAvvisoScreen.apri(context),
      ),
      child: RefreshIndicator(
        onRefresh: viewModel.ricarica,
        edgeOffset: 160,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 200),
          children: [
            const JambIntestazione(titolo: 'Bacheca Avvisi'),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (final filtro in viewModel.filtri) ...[
                    JambChipFiltro(
                      etichetta: filtro.etichetta,
                      selezionato: filtro == viewModel.filtro,
                      onTap: () => viewModel.setFiltro(filtro),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (viewModel.isLoading && viewModel.avvisi.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (viewModel.haErrore)
              JambStatoErrore(
                messaggio: viewModel.errore!,
                onRiprova: viewModel.ricarica,
              )
            else if (viewModel.avvisi.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'Nessun avviso in bacheca.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              for (final avviso in viewModel.avvisi)
                AvvisoCard(
                  avviso: avviso,
                  onTap: () => DettaglioAvvisoScreen.apri(context, avviso),
                ),
          ],
        ),
      ),
    );
  }
}
