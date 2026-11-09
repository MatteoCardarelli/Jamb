import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/repositories/campo_repository.dart';
import 'package:jamb/ui/campo/view_model/campo_view_model.dart';
import 'package:jamb/ui/campo/widgets/campo_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_schermata_elenco.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';

/// Campi e uscite dell'unità attiva.
class CampiScreen extends StatelessWidget {
  const CampiScreen({super.key});

  /// Apre l'elenco dei campi.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CampiScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final branca = context.read<SessionService>().tipoBrancaAttiva;
    return ChangeNotifierProvider(
      create: (context) => CampiViewModel(
        context.read<ICampoRepository>(),
        tipi: TipoCampo.perBranca(branca),
      ),
      child: CampiView(
        onApri: (context, campo) => CampoScreen.apri(context, campo.id),
      ),
    );
  }
}

/// Elenco dei campi; [onApri] porta all'organizzazione di un campo.
class CampiView extends StatelessWidget {
  final void Function(BuildContext, Campo) onApri;

  const CampiView({super.key, required this.onApri});

  /// Chiede quale campo si organizza, poi il titolo, e lo apre.
  Future<void> _nuovo(BuildContext context, CampiViewModel viewModel) async {
    final tipo = await JambDialogs.scegli<TipoCampo>(
      context,
      titolo: 'Nuovo campo',
      messaggio: 'Quale campo vuoi organizzare?',
      opzioni: [for (final t in viewModel.tipi) (t.etichetta, t)],
    );
    if (tipo == null || !context.mounted) return;

    final titolo = await JambDialogs.chiediNome(
      context,
      titolo: tipo.etichetta,
      icona: Icons.park_outlined,
      conferma: 'CREA',
      iniziale: tipo.etichetta,
      etichetta: 'Titolo',
      suggerimento: 'Es. Campo estivo 2027',
      valida: erroreTestoCampo,
    );
    if (titolo == null || !context.mounted) return;

    Campo? creato;
    await eseguiConFeedback(context, () async {
      creato = await viewModel.crea(tipo, titolo);
    });
    final campo = creato;
    if (campo != null && context.mounted) onApri(context, campo);
  }

  Future<void> _elimina(
    BuildContext context,
    CampiViewModel viewModel,
    Campo campo,
  ) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: 'Elimina',
      messaggio:
          'Vuoi eliminare "${campo.titolo}" con pattuglie, compiti e contatti?',
    );
    if (conferma && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.elimina(campo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CampiViewModel>();

    return JambSchermataElenco(
      titolo: 'Campi e uscite',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      children: [
        JambPulsanteSecondario(
          icona: Icons.add_rounded,
          etichetta: 'Nuovo campo o uscita',
          onTap: () => _nuovo(context, viewModel),
        ),
        const SizedBox(height: 16),
        if (viewModel.campi.isEmpty)
          const JambTestoVuoto(
            'Nessun campo in programma.',
            icona: Icons.park_outlined,
            centrato: true,
          ),
        for (final c in viewModel.campi)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onApri(context, c),
              child: JambRiquadro(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.titolo,
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                c.tipo.etichetta,
                                if (c.annoScout.isNotEmpty) c.annoScout,
                              ].join(' · '),
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Elimina',
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFB91C1C),
                        ),
                        onPressed: () => _elimina(context, viewModel, c),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
