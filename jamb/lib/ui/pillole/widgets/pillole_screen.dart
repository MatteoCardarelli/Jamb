import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/pillola.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_schermata_elenco.dart';
import 'package:jamb/ui/pillole/view_model/pillole_view_model.dart';

/// Elenco delle pillole del metodo (US8) e degli spunti di spiritualità (US33).
class PilloleScreen extends StatelessWidget {
  final TipoPillola tipoIniziale;

  const PilloleScreen({super.key, this.tipoIniziale = TipoPillola.metodo});

  /// Apre l'elenco su [tipo]; il ViewModel è quello della Home.
  static Future<void> apri(
    BuildContext context, {
    TipoPillola tipo = TipoPillola.metodo,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PilloleScreen(tipoIniziale: tipo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permessi = context.read<SessionService>().permessi;
    return PilloleView(
      puoModificare: permessi.puoGestireLibreria,
      puoModificareSpiritualita: permessi.assistenteEcclesiastico,
      tipoIniziale: tipoIniziale,
    );
  }
}

/// Contenuto della schermata; le pillole comuni non si modificano mai, le
/// altre solo da chi ne ha il permesso per quel tipo.
class PilloleView extends StatefulWidget {
  final bool puoModificare;
  final bool puoModificareSpiritualita;
  final TipoPillola tipoIniziale;

  const PilloleView({
    super.key,
    required this.puoModificare,
    this.puoModificareSpiritualita = false,
    this.tipoIniziale = TipoPillola.metodo,
  });

  @override
  State<PilloleView> createState() => _PilloleViewState();
}

class _PilloleViewState extends State<PilloleView> {
  late TipoPillola _tipo = widget.tipoIniziale;

  bool get _puoModificare => _tipo == TipoPillola.metodo
      ? widget.puoModificare
      : widget.puoModificareSpiritualita;

  Future<String?> _chiediTesto(
    BuildContext context,
    String titolo, {
    String iniziale = '',
  }) {
    return JambDialogs.chiediNome(
      context,
      titolo: titolo,
      icona: Icons.lightbulb_outline_rounded,
      conferma: 'SALVA',
      iniziale: iniziale,
      etichetta: 'Testo',
      suggerimento: _tipo == TipoPillola.metodo
          ? 'Una breve nozione sul metodo'
          : 'Uno spunto per la Comunità Capi',
      righe: 4,
      valida: errorePillola,
    );
  }

  Future<void> _nuova(BuildContext context, PilloleViewModel viewModel) async {
    final tipo = _tipo;
    final testo = await _chiediTesto(context, 'Nuova pillola');
    if (testo != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.crea(testo, tipo: tipo));
    }
  }

  Future<void> _modifica(
    BuildContext context,
    PilloleViewModel viewModel,
    Pillola p,
  ) async {
    final testo = await _chiediTesto(
      context,
      'Modifica pillola',
      iniziale: p.testo,
    );
    if (testo != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.aggiorna(p, testo));
    }
  }

  Future<void> _elimina(
    BuildContext context,
    PilloleViewModel viewModel,
    Pillola p,
  ) async {
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
    final pillole = viewModel.pilloleDi(_tipo);
    final puoModificare = _puoModificare;

    return JambSchermataElenco(
      titolo: 'Pillole',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final t in TipoPillola.values)
              JambChipFiltro(
                etichetta: t.etichetta,
                selezionato: _tipo == t,
                onTap: () => setState(() => _tipo = t),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (puoModificare) ...[
          JambPulsanteSecondario(
            icona: Icons.add_rounded,
            etichetta: 'Nuova pillola',
            onTap: () => _nuova(context, viewModel),
          ),
          const SizedBox(height: 16),
        ],
        if (pillole.isEmpty)
          JambTestoVuoto(
            _tipo == TipoPillola.metodo
                ? 'Nessuna pillola per questa branca.'
                : 'Nessuno spunto di spiritualità.',
            icona: Icons.lightbulb_outline_rounded,
            centrato: true,
          ),
        for (final p in pillole)
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
                      puoModificare
                          ? 'Del gruppo · tieni premuto per modificare'
                          : 'Del gruppo',
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
    );
  }
}
