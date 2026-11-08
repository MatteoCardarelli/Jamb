import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';
import 'package:jamb/ui/contabilita/view_model/bilancio_gruppo_view_model.dart';
import 'package:jamb/ui/contabilita/widgets/riquadro_bilancio.dart';

/// Bilancio consolidato del gruppo per anno scout (US31), per il Capo Gruppo.
class BilancioGruppoScreen extends StatelessWidget {
  const BilancioGruppoScreen({super.key});

  /// Apre il bilancio di tutte le casse del gruppo.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BilancioGruppoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BilancioGruppoViewModel(context.read<ITransazioneRepository>()),
      child: const _BilancioGruppoView(),
    );
  }
}

class _BilancioGruppoView extends StatelessWidget {
  const _BilancioGruppoView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BilancioGruppoViewModel>();
    final consolidato = viewModel.consolidato;

    return SchermataBilancio(
      titolo: 'Bilancio di Gruppo',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      anni: viewModel.anni,
      annoScelto: viewModel.annoScout,
      onAnno: viewModel.scegliAnno,
      contenuti: [
        RiepilogoBilancio(consolidato.totale),
        for (final cassa in consolidato.casse) ...[
          const SizedBox(height: 12),
          RiquadroBilancio(
            titolo: cassa.nome,
            righe: [
              RigaImporto('Saldo iniziale', cassa.bilancio.saldoIniziale),
              RigaImporto('Entrate', cassa.bilancio.totaleEntrate),
              RigaImporto('Uscite', cassa.bilancio.totaleUscite),
              RigaImporto('Saldo finale', cassa.bilancio.saldoFinale, forte: true),
            ],
          ),
        ],
      ],
    );
  }
}
