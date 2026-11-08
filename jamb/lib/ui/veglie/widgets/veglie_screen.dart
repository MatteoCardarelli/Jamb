import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/veglia.dart';
import 'package:jamb/domain/repositories/veglia_repository.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';
import 'package:jamb/ui/core/widgets/jamb_dettaglio.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';
import 'package:jamb/ui/veglie/view_model/veglie_view_model.dart';

/// Veglie preparate dall'Assistente Ecclesiastico (US32).
class VeglieScreen extends StatelessWidget {
  const VeglieScreen({super.key});

  /// Apre l'elenco delle veglie.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VeglieScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permessi = context.read<SessionService>().permessi;
    return ChangeNotifierProvider(
      create: (context) => VeglieViewModel(context.read<IVegliaRepository>()),
      child: VeglieView(puoModificare: permessi.assistenteEcclesiastico),
    );
  }
}

/// Elenco delle veglie; solo l'Assistente le crea e le modifica.
class VeglieView extends StatelessWidget {
  final bool puoModificare;

  const VeglieView({super.key, required this.puoModificare});

  void _apri(BuildContext context, VeglieViewModel viewModel, Veglia veglia) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _DettaglioVeglia(
        veglia: veglia,
        puoModificare: puoModificare,
        onElimina: () => viewModel.elimina(veglia),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VeglieViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const JambAppBar(titolo: 'Veglie'),
      body: SafeArea(
        top: false,
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.haErrore
                ? JambStatoErrore(messaggio: viewModel.errore!, onRiprova: viewModel.ricarica)
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          JambChipFiltro(
                            etichetta: 'Tutte',
                            selezionato: viewModel.filtro == null,
                            onTap: () => viewModel.setFiltro(null),
                          ),
                          for (final b in BrancaVeglia.values)
                            JambChipFiltro(
                              etichetta: b.etichetta,
                              selezionato: viewModel.filtro == b,
                              onTap: () => viewModel.setFiltro(b),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (puoModificare) ...[
                        JambPulsanteSecondario(
                          icona: Icons.add_rounded,
                          etichetta: 'Nuova veglia',
                          onTap: () => FormVegliaScreen.apri(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (viewModel.veglie.isEmpty)
                        const JambTestoVuoto(
                          'Nessuna veglia.',
                          icona: Icons.nightlight_outlined,
                          centrato: true,
                        ),
                      for (final v in viewModel.veglie)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _apri(context, viewModel, v),
                            child: JambRiquadro(
                              children: [
                                Text(
                                  v.titolo,
                                  style: const TextStyle(fontFamily: 'Lexend', fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${v.branca.etichetta} · ${v.momenti.length} momenti',
                                  style: const TextStyle(fontFamily: 'Lexend', fontSize: 13, color: Color(0xFF64748B)),
                                ),
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

/// Dettaglio di una veglia, con modifica ed eliminazione per l'Assistente.
class _DettaglioVeglia extends StatelessWidget {
  final Veglia veglia;
  final bool puoModificare;
  final Future<void> Function() onElimina;

  const _DettaglioVeglia({required this.veglia, required this.puoModificare, required this.onElimina});

  Future<void> _elimina(BuildContext context) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: 'Elimina veglia',
      messaggio: 'Vuoi eliminare "${veglia.titolo}"? L\'azione non è reversibile.',
    );
    if (!conferma || !context.mounted) return;
    final eliminata = await eseguiConFeedback(context, onElimina);
    if (eliminata && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: JambAppBar(
        titolo: 'Veglia',
        azioni: [
          if (puoModificare) ...[
            IconButton(
              tooltip: 'Modifica',
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF1D2660)),
              onPressed: () {
                Navigator.of(context).pop();
                FormVegliaScreen.apri(context, esistente: veglia);
              },
            ),
            IconButton(
              tooltip: 'Elimina',
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB91C1C)),
              onPressed: () => _elimina(context),
            ),
          ],
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            JambTitoloDettaglio(veglia.titolo),
            const SizedBox(height: 16),
            JambRigaDettaglio(icona: Icons.groups_outlined, testo: 'Per ${veglia.branca.etichetta}'),
            const SizedBox(height: 8),
            for (final m in veglia.momenti) _RigaMomento(momento: m),
          ],
        ),
      ),
    );
  }
}

class _RigaMomento extends StatelessWidget {
  final MomentoVeglia momento;
  final Widget? azioni;

  const _RigaMomento({required this.momento, this.azioni});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  momento.tipo.etichetta.toUpperCase(),
                  style: const TextStyle(fontFamily: 'Lexend', fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                Text(momento.testo, style: const TextStyle(fontFamily: 'Lexend', fontSize: 15, height: 1.4)),
              ],
            ),
          ),
          ?azioni,
        ],
      ),
    );
  }
}

/// Form per creare una veglia o modificare [esistente].
class FormVegliaScreen extends StatelessWidget {
  final Veglia? esistente;

  const FormVegliaScreen({super.key, this.esistente});

  /// Apre il form della veglia.
  static Future<void> apri(BuildContext context, {Veglia? esistente}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FormVegliaScreen(esistente: esistente)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FormVegliaViewModel(context.read<IVegliaRepository>(), esistente: esistente),
      child: const FormVegliaView(),
    );
  }
}

/// Contenuto del form della veglia.
class FormVegliaView extends StatelessWidget {
  const FormVegliaView({super.key});

  Future<void> _nuovoMomento(BuildContext context, FormVegliaViewModel viewModel) async {
    final tipo = await JambDialogs.scegli<TipoMomento>(
      context,
      titolo: 'Nuovo momento',
      messaggio: 'Che momento vuoi aggiungere?',
      opzioni: [for (final t in TipoMomento.values) (t.etichetta, t)],
    );
    if (tipo == null || !context.mounted) return;
    final testo = await JambDialogs.chiediNome(
      context,
      titolo: tipo.etichetta,
      icona: Icons.notes_rounded,
      conferma: 'AGGIUNGI',
      etichetta: 'Testo',
      suggerimento: 'Titolo, riferimento o traccia',
      righe: 4,
      valida: (t) => t.trim().isEmpty ? 'Il testo non può essere vuoto.' : null,
    );
    if (testo != null) viewModel.aggiungiMomento(tipo, testo);
  }

  Future<void> _salva(BuildContext context, FormVegliaViewModel viewModel) async {
    final salvata = await eseguiConFeedback(context, viewModel.salva);
    if (salvata && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FormVegliaViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: JambAppBar(titolo: viewModel.isModifica ? 'Modifica veglia' : 'Nuova veglia'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const JambEtichettaCampo('Titolo'),
          TextFormField(
            initialValue: viewModel.titolo,
            onChanged: viewModel.setTitolo,
            decoration: jambDecorazioneCampo('Es. Veglia di Avvento'),
          ),
          const SizedBox(height: 24),
          const JambEtichettaCampo('Branca'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final b in BrancaVeglia.values)
                JambChipFiltro(
                  etichetta: b.etichetta,
                  selezionato: viewModel.branca == b,
                  onTap: () => viewModel.setBranca(b),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const JambEtichettaCampo('Momenti'),
          if (viewModel.momenti.isEmpty) const JambTestoVuoto('Aggiungi almeno un momento.'),
          for (final (i, m) in viewModel.momenti.indexed)
            _RigaMomento(
              momento: m,
              azioni: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Sposta su',
                    icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                    onPressed: i == 0 ? null : () => viewModel.spostaMomento(i, -1),
                  ),
                  IconButton(
                    tooltip: 'Sposta giù',
                    icon: const Icon(Icons.arrow_downward_rounded, size: 20),
                    onPressed: i == viewModel.momenti.length - 1 ? null : () => viewModel.spostaMomento(i, 1),
                  ),
                  IconButton(
                    tooltip: 'Togli',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => viewModel.rimuoviMomento(i),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          JambPulsanteSecondario(
            icona: Icons.add_rounded,
            etichetta: 'Aggiungi un momento',
            onTap: () => _nuovoMomento(context, viewModel),
          ),
        ],
      ),
      bottomNavigationBar: JambBarraInFondo(
        etichetta: 'SALVA VEGLIA',
        icona: Icons.save_rounded,
        onPressed: viewModel.isValid ? () => _salva(context, viewModel) : null,
      ),
    );
  }
}
