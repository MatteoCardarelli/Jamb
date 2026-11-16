import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';
import 'package:jamb/ui/core/widgets/jamb_errore_in_linea.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_intestazione.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/ragazzi/view_model/aggiungi_ragazzo_view_model.dart';
import 'package:jamb/ui/ragazzi/widgets/scelta_squadriglia_ruolo.dart';

/// Form per aggiungere ragazzi all'unità attiva: nome, cognome, data di
/// nascita, squadriglia e ruolo. «Salva e aggiungi un altro» permette di
/// caricare un'unità intera senza uscire.
class AggiungiRagazzoScreen extends StatelessWidget {
  const AggiungiRagazzoScreen({super.key});

  /// Apre il form dall'elenco dei ragazzi, che si aggiorna da solo.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AggiungiRagazzoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AggiungiRagazzoViewModel(context.read<IScoutRepository>()),
      child: const _AggiungiRagazzoView(),
    );
  }
}

class _AggiungiRagazzoView extends StatefulWidget {
  const _AggiungiRagazzoView();

  @override
  State<_AggiungiRagazzoView> createState() => _AggiungiRagazzoViewState();
}

class _AggiungiRagazzoViewState extends State<_AggiungiRagazzoView> {
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _dataNascita = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _cognome.dispose();
    _dataNascita.dispose();
    super.dispose();
  }

  Future<void> _scegliData(AggiungiRagazzoViewModel viewModel) async {
    final oggi = DateTime.now();
    final scelta = await showDatePicker(
      context: context,
      initialDate:
          viewModel.dataNascita ?? DateTime(oggi.year - 12, oggi.month, 1),
      firstDate: DateTime(oggi.year - 30),
      lastDate: oggi,
      helpText: 'Data di nascita',
    );
    if (scelta == null) return;
    viewModel.setDataNascita(scelta);
    _dataNascita.text = dataInCifre(scelta);
  }

  /// Salva; con [unAltro] svuota il form per il ragazzo successivo, altrimenti
  /// torna all'elenco.
  Future<void> _salva(
    AggiungiRagazzoViewModel viewModel, {
    required bool unAltro,
  }) async {
    final salvato = await eseguiConFeedback(context, viewModel.salva);
    if (!salvato || !mounted) return;
    if (!unAltro) {
      Navigator.of(context).pop();
      return;
    }
    viewModel.preparaProssimo();
    _nome.clear();
    _cognome.clear();
    _dataNascita.clear();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AggiungiRagazzoViewModel>();

    return EmptyBackgroundScreen(
      currentIndex: 1,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 170, 20, 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JambIntestazione(titolo: 'Aggiungi ragazzo'),
                const SizedBox(height: 24),
                if (viewModel.aggiunti > 0) ...[
                  JambTestoVuoto(
                    viewModel.aggiunti == 1
                        ? 'Un ragazzo aggiunto. Puoi continuare con il prossimo.'
                        : '${viewModel.aggiunti} ragazzi aggiunti. Puoi continuare con il prossimo.',
                  ),
                  const SizedBox(height: 8),
                ],

                const JambEtichettaCampo('Nome'),
                TextField(
                  controller: _nome,
                  onChanged: viewModel.setNome,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: jambDecorazioneCampo('Es. Giulia'),
                ),
                const SizedBox(height: 16),

                const JambEtichettaCampo('Cognome'),
                TextField(
                  controller: _cognome,
                  onChanged: viewModel.setCognome,
                  textCapitalization: TextCapitalization.words,
                  decoration: jambDecorazioneCampo('Es. Rossi'),
                ),
                const SizedBox(height: 16),

                const JambEtichettaCampo('Data di nascita (facoltativa)'),
                TextField(
                  controller: _dataNascita,
                  readOnly: true,
                  onTap: () => _scegliData(viewModel),
                  decoration: jambDecorazioneCampo(
                    'Scegli la data',
                    icona: Icons.cake_outlined,
                  ).copyWith(errorText: viewModel.erroreDataNascita),
                ),
                const SizedBox(height: 24),

                // Senza squadriglie caricate si può comunque aggiungere il ragazzo.
                if (viewModel.haErrore)
                  JambErroreInLinea(
                    messaggio:
                        'Squadriglie non disponibili: ${viewModel.errore}',
                    onRiprova: viewModel.ricaricaSquadriglie,
                  ),
                if (viewModel.isLoading) const JambCaricamentoPiccolo(),
                SceltaSquadrigliaRuolo(
                  squadriglie: viewModel.squadriglie,
                  squadriglia: viewModel.squadriglia,
                  ruolo: viewModel.ruolo,
                  onSquadriglia: viewModel.setSquadriglia,
                  onRuolo: viewModel.setRuolo,
                ),
                const SizedBox(height: 16),

                JambPulsanteSecondario(
                  icona: Icons.playlist_add_rounded,
                  etichetta: 'Salva e aggiungi un altro',
                  onTap: viewModel.isValid
                      ? () => _salva(viewModel, unAltro: true)
                      : null,
                ),
              ],
            ),
          ),

          // BARRA DI AZIONE INFERIORE (sopra la barra di navigazione)
          Positioned(
            bottom: 130,
            left: 20,
            right: 20,
            child: JambBarraAzioni(
              etichetta: 'AGGIUNGI',
              icona: Icons.person_add_alt_1_rounded,
              onPressed: viewModel.isValid
                  ? () => _salva(viewModel, unAltro: false)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
