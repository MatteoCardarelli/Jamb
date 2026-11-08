import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/bilancio.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';
import 'package:jamb/ui/contabilita/view_model/bilancio_view_model.dart';
import 'package:jamb/ui/contabilita/widgets/riquadro_bilancio.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';

/// Bilancio consolidato dell'unità per anno scout (US26).
class BilancioScreen extends StatelessWidget {
  const BilancioScreen({super.key});

  /// Apre il bilancio dell'unità attiva.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BilancioScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BilancioViewModel(
        context.read<ITransazioneRepository>(),
        context.read<IDocumentoRepository>(),
      ),
      child: const _BilancioView(),
    );
  }
}

class _BilancioView extends StatelessWidget {
  const _BilancioView();

  /// Archivia con [archivia] e conferma all'utente dove trovare il file.
  Future<void> _archivia(
    BuildContext context,
    Future<void> Function({required String unita}) archivia,
  ) async {
    final unita = context.read<SessionService>().nomeUnitaAttiva;
    final messenger = ScaffoldMessenger.of(context);
    final fatto = await eseguiConFeedback(context, () => archivia(unita: unita));
    if (fatto) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Bilancio archiviato nel Drive di Branca.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BilancioViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const JambAppBar(titolo: 'Bilancio'),
      body: SafeArea(
        top: false,
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.haErrore
                ? JambStatoErrore(messaggio: viewModel.errore!, onRiprova: viewModel.ricarica)
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      SelettoreAnnoScout(
                        anni: viewModel.anni,
                        selezionato: viewModel.annoScout,
                        onScelta: viewModel.scegliAnno,
                      ),
                      const SizedBox(height: 16),
                      _Riepilogo(viewModel.bilancio),
                      const SizedBox(height: 16),
                      JambPulsanteSecondario(
                        icona: Icons.picture_as_pdf_outlined,
                        etichetta: 'Archivia nel Drive (PDF)',
                        onTap: () => _archivia(context, viewModel.archiviaPdf),
                      ),
                      const SizedBox(height: 8),
                      JambPulsanteSecondario(
                        icona: Icons.table_chart_outlined,
                        etichetta: 'Archivia nel Drive (CSV)',
                        onTap: () => _archivia(context, viewModel.archiviaCsv),
                      ),
                    ],
                  ),
      ),
    );
  }
}

/// Scelta dell'anno scout di un bilancio.
class SelettoreAnnoScout extends StatelessWidget {
  final List<String> anni;
  final String selezionato;
  final ValueChanged<String> onScelta;

  const SelettoreAnnoScout({
    super.key,
    required this.anni,
    required this.selezionato,
    required this.onScelta,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final anno in anni)
          JambChipFiltro(
            etichetta: anno,
            selezionato: anno == selezionato,
            onTap: () => onScelta(anno),
          ),
      ],
    );
  }
}

/// Saldo iniziale, entrate e uscite per categoria e saldo finale.
class _Riepilogo extends StatelessWidget {
  final Bilancio bilancio;

  const _Riepilogo(this.bilancio);

  List<Widget> _perCategoria(Map<Categoria, int> importi, String vuoto, String totale, int somma) => [
        if (importi.isEmpty) JambTestoVuoto(vuoto),
        for (final c in Categoria.values)
          if (importi[c] case final importo?) RigaImporto(c.etichetta, importo),
        const Divider(),
        RigaImporto(totale, somma, forte: true),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RiquadroBilancio(
          titolo: 'Saldo',
          righe: [
            RigaImporto('Saldo iniziale', bilancio.saldoIniziale),
            RigaImporto('Saldo finale', bilancio.saldoFinale, forte: true),
          ],
        ),
        const SizedBox(height: 12),
        RiquadroBilancio(
          titolo: 'Entrate',
          righe: _perCategoria(
              bilancio.entrate, "Nessuna entrata nell'anno.", 'Totale entrate', bilancio.totaleEntrate),
        ),
        const SizedBox(height: 12),
        RiquadroBilancio(
          titolo: 'Uscite',
          righe: _perCategoria(
              bilancio.uscite, "Nessuna uscita nell'anno.", 'Totale uscite', bilancio.totaleUscite),
        ),
      ],
    );
  }
}
