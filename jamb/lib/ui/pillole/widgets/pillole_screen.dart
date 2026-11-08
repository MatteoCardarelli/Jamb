import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/pillola.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';
import 'package:jamb/ui/pillole/view_model/pillole_view_model.dart';

/// Elenco delle pillole del metodo della branca (US8).
class PilloleScreen extends StatelessWidget {
  const PilloleScreen({super.key});

  /// Apre l'elenco; il ViewModel è quello della Home.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PilloleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PilloleView(
      puoModificare: context.read<SessionService>().permessi.puoGestireLibreria,
    );
  }
}

/// Contenuto della schermata; le pillole comuni non si modificano mai, le
/// altre solo se [puoModificare].
class PilloleView extends StatelessWidget {
  final bool puoModificare;

  const PilloleView({super.key, required this.puoModificare});

  Future<String?> _chiediTesto(BuildContext context, String titolo, {String iniziale = ''}) {
    return JambDialogs.chiediNome(
      context,
      titolo: titolo,
      icona: Icons.lightbulb_outline_rounded,
      conferma: 'SALVA',
      iniziale: iniziale,
      etichetta: 'Testo',
      suggerimento: 'Una breve nozione sul metodo',
      righe: 4,
      valida: errorePillola,
    );
  }

  Future<void> _nuova(BuildContext context, PilloleViewModel viewModel) async {
    final testo = await _chiediTesto(context, 'Nuova pillola');
    if (testo != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.crea(testo));
    }
  }

  Future<void> _modifica(BuildContext context, PilloleViewModel viewModel, Pillola p) async {
    final testo = await _chiediTesto(context, 'Modifica pillola', iniziale: p.testo);
    if (testo != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.aggiorna(p, testo));
    }
  }

  Future<void> _elimina(BuildContext context, PilloleViewModel viewModel, Pillola p) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: 'Elimina pillola',
      messaggio: "Vuoi eliminare questa pillola? L'azione non è reversibile.",
    );
    if (conferma && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.elimina(p));
    }
  }

  void _menu(BuildContext context, PilloleViewModel viewModel, Pillola p) {
    mostraMenuJamb(
      context,
      titolo: 'Pillola',
      voci: (_) => [
        JambVoceMenu(
          icona: Icons.edit_outlined,
          etichetta: 'Modifica',
          onTap: () => _modifica(context, viewModel, p),
        ),
        JambVoceMenu(
          icona: Icons.delete_outline_rounded,
          etichetta: 'Elimina',
          pericolosa: true,
          onTap: () => _elimina(context, viewModel, p),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PilloleViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const JambAppBar(titolo: 'Pillole del metodo'),
      body: SafeArea(
        top: false,
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.haErrore
                ? JambStatoErrore(messaggio: viewModel.errore!, onRiprova: viewModel.ricarica)
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (puoModificare) ...[
                        JambPulsanteSecondario(
                          icona: Icons.add_rounded,
                          etichetta: 'Nuova pillola',
                          onTap: () => _nuova(context, viewModel),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (viewModel.pillole.isEmpty)
                        const JambTestoVuoto(
                          'Nessuna pillola per questa branca.',
                          icona: Icons.lightbulb_outline_rounded,
                          centrato: true,
                        ),
                      for (final p in viewModel.pillole)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onLongPress: puoModificare && !p.comune
                                ? () => _menu(context, viewModel, p)
                                : null,
                            child: JambRiquadro(
                              children: [
                                Text(
                                  p.testo,
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                if (!p.comune) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    puoModificare ? 'Del gruppo · tieni premuto per modificare' : 'Del gruppo',
                                    style: const TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
