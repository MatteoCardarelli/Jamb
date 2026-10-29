import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/avviso.dart';
import 'package:jamb/domain/repositories/avviso_repository.dart';
import 'package:jamb/ui/bacheca/view_model/dettaglio_avviso_view_model.dart';
import 'package:jamb/ui/bacheca/widgets/form_avviso_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_dettaglio.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';

/// Dettaglio di un avviso della bacheca, con modifica ed eliminazione.
/// Aprirlo segna l'avviso come letto.
class DettaglioAvvisoScreen extends StatelessWidget {
  final Avviso avviso;

  const DettaglioAvvisoScreen({super.key, required this.avviso});

  /// Apre il dettaglio di [avviso] (dalla bacheca).
  static Future<void> apri(BuildContext context, Avviso avviso) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DettaglioAvvisoScreen(avviso: avviso)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DettaglioAvvisoViewModel(avviso, context.read<IAvvisoRepository>()),
      child: const _DettaglioAvvisoView(),
    );
  }
}

class _DettaglioAvvisoView extends StatelessWidget {
  const _DettaglioAvvisoView();

  Future<void> _modifica(
    BuildContext context,
    DettaglioAvvisoViewModel viewModel,
  ) async {
    final aggiornato = await FormAvvisoScreen.apri(
      context,
      avvisoEsistente: viewModel.avviso,
    );
    if (aggiornato != null) viewModel.aggiornato(aggiornato);
  }

  Future<void> _confermaEliminazione(
    BuildContext context,
    DettaglioAvvisoViewModel viewModel,
  ) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: "Elimina avviso",
      messaggio:
          "Vuoi eliminare \"${viewModel.avviso.titolo}\"? L'azione non è reversibile.",
    );
    if (!conferma || !context.mounted) return;

    final eliminato = await eseguiConFeedback(context, viewModel.elimina);
    if (eliminato && context.mounted) {
      Navigator.of(context).pop(); // Torna alla bacheca
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DettaglioAvvisoViewModel>();
    final avviso = viewModel.avviso;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: JambAppBar(
        titolo: "Avviso",
        azioni: [
          IconButton(
            tooltip: 'Modifica',
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF1D2660)),
            onPressed: () => _modifica(context, viewModel),
          ),
          IconButton(
            tooltip: 'Elimina',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFB91C1C),
            ),
            onPressed: () => _confermaEliminazione(context, viewModel),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JambTitoloDettaglio(avviso.titolo),
            const SizedBox(height: 24),
            JambRigaDettaglio(
              icona: avviso.perTuttaLUnita
                  ? Icons.groups_rounded
                  : Icons.shield_rounded,
              testo: viewModel.destinatari,
            ),
            if (avviso.autore.isNotEmpty)
              JambRigaDettaglio(
                icona: Icons.person_outline_rounded,
                testo: avviso.autore,
              ),
            JambRigaDettaglio(
              icona: Icons.schedule_rounded,
              testo: viewModel.pubblicato,
            ),
            const SizedBox(height: 16),
            SelectableText(
              avviso.contenuto,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF1E293B),
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
