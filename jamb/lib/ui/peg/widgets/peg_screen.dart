import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/peg.dart';
import 'package:jamb/domain/repositories/peg_repository.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_schermata_elenco.dart';
import 'package:jamb/ui/peg/view_model/peg_view_model.dart';

/// Progetto Educativo di Gruppo.
class PegScreen extends StatelessWidget {
  const PegScreen({super.key});

  /// Apre il PEG del gruppo.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PegScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final permessi = context.read<SessionService>().permessi;
    return ChangeNotifierProvider(
      create: (context) => PegViewModel(context.read<IPegRepository>()),
      child: PegView(
        puoModificare: permessi.puoScriverePeg,
        // L'Assistente senza unità non legge i Programmi d'Unità: per lui
        // ogni obiettivo sembrerebbe trascurato.
        conAvanzamento: permessi.puoUsareAreaCapi,
      ),
    );
  }
}

/// Contenuto del PEG; senza [puoModificare] si consulta soltanto.
class PegView extends StatelessWidget {
  final bool puoModificare;
  final bool conAvanzamento;

  const PegView({
    super.key,
    required this.puoModificare,
    this.conAvanzamento = true,
  });

  Future<void> _testo(
    BuildContext context, {
    required String titolo,
    required String iniziale,
    required String etichetta,
    required String suggerimento,
    required Future<void> Function(String) salva,
    int righe = 1,
    String? Function(String)? valida,
  }) async {
    final testo = await JambDialogs.chiediNome(
      context,
      titolo: titolo,
      icona: Icons.edit_outlined,
      conferma: 'SALVA',
      iniziale: iniziale,
      etichetta: etichetta,
      suggerimento: suggerimento,
      righe: righe,
      valida: valida,
    );
    if (testo != null && context.mounted) {
      await eseguiConFeedback(context, () => salva(testo));
    }
  }

  void _menu(BuildContext context, PegViewModel viewModel, PegObiettivo o) {
    mostraMenuJamb(
      context,
      titolo: o.titolo,
      voci: (_) => [
        JambVoceMenu(
          icona: Icons.edit_outlined,
          etichetta: 'Rinomina',
          onTap: () => _testo(
            context,
            titolo: 'Rinomina',
            iniziale: o.titolo,
            etichetta: 'Titolo',
            suggerimento: 'Es. Educare all\'essenzialità',
            valida: erroreTitoloPeg,
            salva: (t) => viewModel.rinominaObiettivo(o, t),
          ),
        ),
        JambVoceMenu(
          icona: Icons.notes_rounded,
          etichetta: 'Descrizione',
          onTap: () => _testo(
            context,
            titolo: 'Descrizione',
            iniziale: o.descrizione,
            etichetta: 'Descrizione',
            suggerimento: 'Cosa significa per il gruppo',
            righe: 4,
            salva: (t) => viewModel.descriviObiettivo(o, t),
          ),
        ),
        JambVoceMenu(
          icona: Icons.delete_outline_rounded,
          etichetta: 'Elimina',
          pericolosa: true,
          onTap: () => _elimina(context, viewModel, o),
        ),
      ],
    );
  }

  Future<void> _elimina(
    BuildContext context,
    PegViewModel viewModel,
    PegObiettivo o,
  ) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: 'Elimina obiettivo',
      messaggio:
          'Vuoi eliminare "${o.titolo}"? I Programmi d\'Unità collegati restano, senza collegamento.',
    );
    if (conferma && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.eliminaObiettivo(o));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PegViewModel>();
    final peg = viewModel.peg;

    return JambSchermataElenco(
      titolo: 'Progetto Educativo',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      children: [
        JambRiquadro(
          titolo: peg.titolo.isEmpty ? 'PEG' : peg.titolo,
          children: [
            if (peg.premessa.isEmpty)
              const JambTestoVuoto(
                'Il Capo Gruppo non ha ancora scritto la premessa.',
              )
            else
              Text(
                peg.premessa,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            if (puoModificare) ...[
              const SizedBox(height: 12),
              JambPulsanteSecondario(
                icona: Icons.title_rounded,
                etichetta: 'Modifica il titolo',
                onTap: () => _testo(
                  context,
                  titolo: 'Titolo del PEG',
                  iniziale: peg.titolo,
                  etichetta: 'Titolo',
                  suggerimento: 'Es. Sulla stessa strada',
                  salva: viewModel.salvaTitolo,
                ),
              ),
              const SizedBox(height: 8),
              JambPulsanteSecondario(
                icona: Icons.edit_note_rounded,
                etichetta: 'Modifica la premessa',
                onTap: () => _testo(
                  context,
                  titolo: 'Premessa',
                  iniziale: peg.premessa,
                  etichetta: 'Premessa',
                  suggerimento: 'La direzione comune del gruppo',
                  righe: 6,
                  salva: viewModel.salvaPremessa,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        JambRiquadro(
          titolo: conAvanzamento && viewModel.critici > 0
              ? 'Obiettivi · ${viewModel.critici} critici'
              : 'Obiettivi',
          children: [
            if (viewModel.avanzamenti.isEmpty)
              const JambTestoVuoto('Nessun obiettivo nel PEG.'),
            for (final a in viewModel.avanzamenti)
              _RigaObiettivo(
                avanzamento: a,
                conAvanzamento: conAvanzamento,
                onTap: puoModificare
                    ? () => _menu(context, viewModel, a.obiettivo)
                    : null,
              ),
            if (puoModificare) ...[
              const SizedBox(height: 8),
              JambPulsanteSecondario(
                icona: Icons.add_rounded,
                etichetta: 'Nuovo obiettivo',
                onTap: () => _testo(
                  context,
                  titolo: 'Nuovo obiettivo',
                  iniziale: '',
                  etichetta: 'Titolo',
                  suggerimento: 'Es. Educare all\'essenzialità',
                  valida: erroreTitoloPeg,
                  salva: viewModel.creaObiettivo,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Un obiettivo con il suo avanzamento e l'eventuale segnalazione di criticità.
class _RigaObiettivo extends StatelessWidget {
  final AvanzamentoPeg avanzamento;
  final bool conAvanzamento;
  final VoidCallback? onTap;

  const _RigaObiettivo({
    required this.avanzamento,
    required this.conAvanzamento,
    this.onTap,
  });

  String get _stato {
    final media = avanzamento.media;
    if (media == null) return 'Nessun Programma collegato';
    return 'Media ${media.toStringAsFixed(1).replaceAll('.', ',')} su 5 · ${avanzamento.gradi.length} collegati';
  }

  @override
  Widget build(BuildContext context) {
    final o = avanzamento.obiettivo;
    final colore = avanzamento.critico
        ? const Color(0xFFB91C1C)
        : const Color(0xFF1B5E20);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              o.titolo,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (o.descrizione.isNotEmpty)
              Text(
                o.descrizione,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            if (conAvanzamento) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: avanzamento.frazione ?? 0,
                color: colore,
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 4),
              Text(
                avanzamento.critico ? 'Punto critico · $_stato' : _stato,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 12,
                  color: colore,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
