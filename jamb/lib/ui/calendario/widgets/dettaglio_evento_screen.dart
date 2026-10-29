import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'etichette_categorie.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_dettaglio.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';
import '../view_model/dettaglio_evento_view_model.dart';
import 'form_evento_screen.dart';

/// Dettaglio di un evento del calendario, con modifica ed eliminazione.
class DettaglioEventoScreen extends StatelessWidget {
  final Evento evento;

  const DettaglioEventoScreen({super.key, required this.evento});

  /// Apre il dettaglio di [evento] (dagli elenchi del calendario).
  static Future<void> apri(BuildContext context, Evento evento) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DettaglioEventoScreen(evento: evento)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DettaglioEventoViewModel(evento, context.read<IEventoRepository>()),
      child: const _DettaglioEventoView(),
    );
  }
}

class _DettaglioEventoView extends StatelessWidget {
  const _DettaglioEventoView();

  Future<void> _modifica(
    BuildContext context,
    DettaglioEventoViewModel viewModel,
  ) async {
    final aggiornato = await Navigator.of(context).push<Evento>(
      MaterialPageRoute(
        builder: (_) => FormEventoScreen(eventoEsistente: viewModel.evento),
      ),
    );
    if (aggiornato != null) viewModel.aggiornato(aggiornato);
  }

  Future<void> _confermaEliminazione(
    BuildContext context,
    DettaglioEventoViewModel viewModel,
  ) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: "Elimina evento",
      messaggio:
          "Vuoi eliminare \"${viewModel.evento.titolo}\"? L'azione non è reversibile.",
    );
    if (!conferma || !context.mounted) return;

    final eliminato = await eseguiConFeedback(context, viewModel.elimina);
    if (eliminato && context.mounted) {
      Navigator.of(context).pop(); // Torna al calendario
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DettaglioEventoViewModel>();
    final evento = viewModel.evento;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: JambAppBar(
        titolo: "Dettaglio Evento",
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
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: evento.colorePrincipale,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            JambTitoloDettaglio(evento.titolo),
            const SizedBox(height: 24),
            JambRigaDettaglio(icona: Icons.schedule_rounded, testo: viewModel.quando),
            if (evento.luogo.isNotEmpty)
              JambRigaDettaglio(icona: Icons.location_on_outlined, testo: evento.luogo),
            const SizedBox(height: 16),
            EtichetteCategorie(categorie: evento.categorie),
          ],
        ),
      ),
    );
  }
}
