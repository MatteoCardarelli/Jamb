import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/incarichi.dart';
import 'package:jamb/domain/repositories/incarichi_repository.dart';
import 'package:jamb/ui/assistente/view_model/assistenti_view_model.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_schermata_elenco.dart';

/// Nomina dell'Assistente Ecclesiastico, per il Capo Gruppo.
class AssistentiScreen extends StatelessWidget {
  const AssistentiScreen({super.key});

  /// Apre la schermata delle nomine.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AssistentiScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AssistentiViewModel(context.read<IIncarichiRepository>()),
      child: const AssistentiView(),
    );
  }
}

/// Contenuto della schermata delle nomine.
class AssistentiView extends StatelessWidget {
  const AssistentiView({super.key});

  Future<void> _nomina(
    BuildContext context,
    AssistentiViewModel viewModel,
  ) async {
    final scelta = await JambDialogs.scegli<PersonaGruppo>(
      context,
      titolo: 'Nomina',
      messaggio: 'Chi è l\'Assistente Ecclesiastico del gruppo?',
      opzioni: [for (final p in viewModel.candidati) (p.nome, p)],
    );
    if (scelta != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.nomina(scelta));
    }
  }

  Future<void> _revoca(
    BuildContext context,
    AssistentiViewModel viewModel,
    PersonaGruppo p,
  ) async {
    final conferma = await JambDialogs.conferma(
      context,
      titolo: 'Togli incarico',
      messaggio:
          'Vuoi togliere a ${p.nome} l\'incarico di Assistente Ecclesiastico?',
      etichetta: 'TOGLI',
    );
    if (conferma && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.revoca(p));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AssistentiViewModel>();

    return JambSchermataElenco(
      titolo: 'Assistente Ecclesiastico',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      children: [
        JambRiquadro(
          titolo: 'Nominati',
          children: [
            if (viewModel.assistenti.isEmpty)
              const JambTestoVuoto('Nessun Assistente nominato.'),
            for (final p in viewModel.assistenti)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  p.nome,
                  style: const TextStyle(fontFamily: 'Lexend'),
                ),
                trailing: IconButton(
                  tooltip: 'Togli incarico',
                  icon: const Icon(
                    Icons.person_remove_outlined,
                    color: Color(0xFFB91C1C),
                  ),
                  onPressed: () => _revoca(context, viewModel, p),
                ),
              ),
            if (viewModel.candidati.isNotEmpty) ...[
              const SizedBox(height: 8),
              JambPulsanteSecondario(
                icona: Icons.person_add_alt_outlined,
                etichetta: 'Nomina',
                onTap: () => _nomina(context, viewModel),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
