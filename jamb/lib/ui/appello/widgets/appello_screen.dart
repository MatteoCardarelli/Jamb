import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/domain/repositories/evento_repository.dart';
import 'package:jamb/domain/repositories/presenza_repository.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/appello/view_model/appello_view_model.dart';
import 'package:jamb/ui/appello/widgets/riga_appello.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';
import 'package:jamb/ui/core/widgets/jamb_dettaglio.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';

/// Appello delle presenze a un evento (US16), dal dettaglio dell'evento:
/// i ragazzi dell'unità per squadriglia, ciascuno da segnare presente,
/// assente o giustificato. Uscendo con presenze non salvate chiede conferma.
class AppelloScreen extends StatelessWidget {
  final Evento evento;

  const AppelloScreen({super.key, required this.evento});

  /// Apre l'appello di [evento].
  static Future<void> apri(BuildContext context, Evento evento) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AppelloScreen(evento: evento)),
    );
  }

  /// Apre dall'azione rapida della Home l'appello dell'evento scelto da
  /// [eventoPerAppello] (in corso, imminente o recente); se non ce n'è
  /// nessuno lo dice e rimanda al calendario.
  static Future<void> apriDaHome(BuildContext context) async {
    final repository = context.read<IEventoRepository>();
    final messenger = ScaffoldMessenger.of(context);
    Evento? evento;
    final letti = await eseguiConFeedback(context, () async {
      evento = eventoPerAppello(await repository.getEventi(), DateTime.now());
    });
    if (!letti || !context.mounted) return;

    final scelto = evento;
    if (scelto == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text(
          "Nessun evento in corso o recente: apri l'appello dal dettaglio di un evento nel calendario.",
        ),
      ));
      return;
    }
    await apri(context, scelto);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppelloViewModel(
        evento,
        context.read<IScoutRepository>(),
        context.read<IPresenzaRepository>(),
      ),
      child: const _AppelloView(),
    );
  }
}

class _AppelloView extends StatelessWidget {
  const _AppelloView();

  Future<void> _salva(BuildContext context, AppelloViewModel viewModel) async {
    final salvato = await eseguiConFeedback(context, viewModel.salva);
    if (salvato && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _confermaUscita(BuildContext context) async {
    final esci = await JambDialogs.conferma(
      context,
      titolo: "Appello non salvato",
      messaggio: "Le presenze segnate andranno perse.",
      etichetta: "ESCI",
    );
    if (esci && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppelloViewModel>();
    final pronto = !viewModel.isLoading && !viewModel.haErrore;

    return PopScope(
      canPop: !viewModel.modificato,
      onPopInvokedWithResult: (uscito, _) {
        if (!uscito) _confermaUscita(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: JambAppBar(
          titolo: "Appello",
          azioni: [
            TextButton(
              onPressed: pronto ? viewModel.tuttiPresenti : null,
              child: const Text("Tutti presenti"),
            ),
          ],
        ),
        body: _corpo(viewModel),
        bottomNavigationBar: JambBarraInFondo(
          etichetta: "SALVA APPELLO",
          icona: Icons.save_rounded,
          onPressed: viewModel.modificato ? () => _salva(context, viewModel) : null,
        ),
      ),
    );
  }

  Widget _corpo(AppelloViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.haErrore) {
      return JambStatoErrore(
        messaggio: viewModel.errore!,
        onRiprova: viewModel.ricarica,
      );
    }

    final gruppi = viewModel.perSquadriglia;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        JambTitoloDettaglio(viewModel.evento.titolo),
        const SizedBox(height: 8),
        Text(
          viewModel.riepilogo,
          style: const TextStyle(color: Color(0xFF64748B), fontFamily: 'Lexend'),
        ),
        const SizedBox(height: 24),
        if (gruppi.isEmpty)
          const JambTestoVuoto("Nessun ragazzo nell'unità."),
        for (final gruppo in gruppi.entries) ...[
          JambEtichettaCampo(gruppo.key),
          for (final ragazzo in gruppo.value)
            RigaAppello(
              nome: ragazzo.nome,
              stato: viewModel.statoDi(ragazzo.id),
              onCambia: (stato) => viewModel.imposta(ragazzo.id, stato),
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
