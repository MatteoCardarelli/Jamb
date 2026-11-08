import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/formazione.dart';
import 'package:jamb/domain/repositories/formazione_repository.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';
import 'package:jamb/ui/profilo/view_model/profilo_view_model.dart';
import 'package:jamb/ui/profilo/widgets/formazione_coca_screen.dart';
import 'package:jamb/ui/profilo/widgets/sezioni_formazione.dart';

/// Profilo del capo connesso: iter formativo e Progetto del Capo.
class ProfiloScreen extends StatelessWidget {
  const ProfiloScreen({super.key});

  /// Apre il profilo dell'utente connesso.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfiloScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionService>();
    return ChangeNotifierProvider(
      create: (context) => ProfiloViewModel(context.read<IFormazioneRepository>()),
      child: ProfiloView(puoVedereCoca: session.permessi.puoVedereFormazioneCoca),
    );
  }
}

/// Contenuto del profilo; [puoVedereCoca] mostra l'accesso alla formazione di
/// tutta la Co.Ca.
class ProfiloView extends StatelessWidget {
  final bool puoVedereCoca;

  const ProfiloView({super.key, required this.puoVedereCoca});

  Future<void> _scegliData(
    BuildContext context,
    ProfiloViewModel viewModel,
    TappaFormativa tappa,
    DateTime iniziale,
  ) async {
    final data = await showDatePicker(
      context: context,
      initialDate: iniziale,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      locale: const Locale('it', 'IT'),
    );
    if (data != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.compiTappa(tappa, data));
    }
  }

  void _tappa(BuildContext context, ProfiloViewModel viewModel, TappaFormativa tappa) {
    TappaCompiuta? compiuta;
    for (final t in viewModel.tappe) {
      if (t.tappa == tappa) compiuta = t;
    }
    final attuale = compiuta;
    if (attuale == null) {
      _scegliData(context, viewModel, tappa, DateTime.now());
      return;
    }
    mostraMenuJamb(
      context,
      titolo: tappa.etichetta,
      voci: (_) => [
        JambVoceMenu(
          icona: Icons.event_outlined,
          etichetta: 'Cambia data',
          onTap: () => _scegliData(context, viewModel, tappa, attuale.data),
        ),
        JambVoceMenu(
          icona: Icons.undo_rounded,
          etichetta: 'Segna come da fare',
          pericolosa: true,
          onTap: () => eseguiConFeedback(context, () => viewModel.rimuoviTappa(tappa)),
        ),
      ],
    );
  }

  Future<void> _modificaTesto(BuildContext context, ProfiloViewModel viewModel) async {
    final testo = await JambDialogs.chiediNome(
      context,
      titolo: 'Progetto del Capo',
      icona: Icons.edit_note_rounded,
      conferma: 'SALVA',
      iniziale: viewModel.progetto.testo,
      etichetta: 'Testo',
      suggerimento: 'Dove vuoi crescere come capo?',
      righe: 6,
    );
    if (testo != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.salvaTesto(testo));
    }
  }

  Future<void> _nuovoPasso(BuildContext context, ProfiloViewModel viewModel) async {
    final titolo = await JambDialogs.chiediNome(
      context,
      titolo: 'Nuovo passo',
      icona: Icons.flag_outlined,
      conferma: 'AGGIUNGI',
      etichetta: 'Passo',
      suggerimento: 'Es. Partecipare al CFM',
      valida: (t) => t.trim().isEmpty ? 'Il passo non può essere vuoto.' : null,
    );
    if (titolo != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.aggiungiPasso(titolo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfiloViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const JambAppBar(titolo: 'Il mio profilo'),
      body: SafeArea(
        top: false,
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.haErrore
                ? JambStatoErrore(messaggio: viewModel.errore!, onRiprova: viewModel.ricarica)
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      RiquadroIter(
                        tappe: viewModel.tappe,
                        onTappa: (t) => _tappa(context, viewModel, t),
                      ),
                      const SizedBox(height: 16),
                      RiquadroProgetto(
                        progetto: viewModel.progetto,
                        nota: 'Lo leggete solo tu e il Capo Gruppo. Tocca il testo per modificarlo.',
                        onModificaTesto: () => _modificaTesto(context, viewModel),
                        onInvertiPasso: (i) =>
                            eseguiConFeedback(context, () => viewModel.invertiPasso(i)),
                        onRimuoviPasso: (i) =>
                            eseguiConFeedback(context, () => viewModel.rimuoviPasso(i)),
                        azioni: [
                          const SizedBox(height: 8),
                          JambPulsanteSecondario(
                            icona: Icons.add_rounded,
                            etichetta: 'Aggiungi un passo',
                            onTap: () => _nuovoPasso(context, viewModel),
                          ),
                        ],
                      ),
                      if (puoVedereCoca) ...[
                        const SizedBox(height: 16),
                        JambPulsanteSecondario(
                          icona: Icons.school_outlined,
                          etichetta: 'Formazione della Co.Ca.',
                          onTap: () => FormazioneCocaScreen.apri(context),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}
