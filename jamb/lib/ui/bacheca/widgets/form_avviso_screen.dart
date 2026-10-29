import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/avviso.dart';
import 'package:jamb/domain/repositories/avviso_repository.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/bacheca/view_model/form_avviso_view_model.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';
import 'package:jamb/ui/core/widgets/jamb_errore_in_linea.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';

/// Form per pubblicare un avviso o modificare [avvisoEsistente]: oggetto,
/// messaggio e destinatari (tutta l'unità o una squadriglia), come da mockup.
class FormAvvisoScreen extends StatelessWidget {
  final Avviso? avvisoEsistente;

  const FormAvvisoScreen({super.key, this.avvisoEsistente});

  /// Apre il form; restituisce l'avviso salvato, o `null` se l'utente esce.
  /// Usato dalla bacheca, dal dettaglio e dalle azioni rapide della Home.
  static Future<Avviso?> apri(BuildContext context, {Avviso? avvisoEsistente}) {
    return Navigator.of(context).push<Avviso>(
      MaterialPageRoute(
        builder: (_) => FormAvvisoScreen(avvisoEsistente: avvisoEsistente),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FormAvvisoViewModel(
        context.read<IAvvisoRepository>(),
        context.read<IScoutRepository>(),
        avvisoEsistente: avvisoEsistente,
      ),
      child: const _FormAvvisoView(),
    );
  }
}

class _FormAvvisoView extends StatelessWidget {
  const _FormAvvisoView();

  Future<void> _salva(BuildContext context, FormAvvisoViewModel viewModel) async {
    Avviso? avviso;
    final salvato = await eseguiConFeedback(context, () async {
      avviso = await viewModel.salva();
    });
    if (salvato && context.mounted) Navigator.of(context).pop(avviso);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FormAvvisoViewModel>();

    return EmptyBackgroundScreen(
      currentIndex: 0,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 170, 20, 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JambEtichettaCampo("Oggetto dell'avviso"),
                TextFormField(
                  initialValue: viewModel.titolo,
                  onChanged: viewModel.setTitolo,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: jambDecorazioneCampo('Es. Ritrovo per il bivacco'),
                ),
                const SizedBox(height: 24),

                const JambEtichettaCampo('Messaggio'),
                TextFormField(
                  initialValue: viewModel.contenuto,
                  onChanged: viewModel.setContenuto,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 4,
                  maxLines: 8,
                  decoration: jambDecorazioneCampo('Scrivi qui i dettagli per gli altri capi…'),
                ),
                const SizedBox(height: 24),

                const JambEtichettaCampo('Destinatari'),
                // Senza squadriglie caricate si può comunque scrivere a tutta l'unità.
                if (viewModel.haErrore)
                  JambErroreInLinea(
                    messaggio: 'Squadriglie non disponibili: ${viewModel.errore}',
                    onRiprova: viewModel.ricaricaSquadriglie,
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    JambChipFiltro(
                      etichetta: "Tutta l'unità",
                      icona: Icons.groups_rounded,
                      selezionato: viewModel.squadriglia == null,
                      onTap: () => viewModel.setSquadriglia(null),
                    ),
                    for (final squadriglia in viewModel.squadriglieDisponibili)
                      JambChipFiltro(
                        etichetta: squadriglia,
                        icona: Icons.shield_rounded,
                        selezionato: viewModel.squadriglia == squadriglia,
                        onTap: () => viewModel.setSquadriglia(squadriglia),
                      ),
                  ],
                ),
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),

          // BARRA DI AZIONE INFERIORE (sopra la barra di navigazione)
          Positioned(
            bottom: 130,
            left: 20,
            right: 20,
            child: JambBarraAzioni(
              etichetta: viewModel.isModifica ? 'SALVA MODIFICHE' : 'PUBBLICA AVVISO',
              icona: viewModel.isModifica ? Icons.save_rounded : Icons.send_rounded,
              onPressed: viewModel.isValid ? () => _salva(context, viewModel) : null,
            ),
          ),
        ],
      ),
    );
  }
}
