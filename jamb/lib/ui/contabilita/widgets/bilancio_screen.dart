import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';
import 'package:jamb/ui/contabilita/view_model/bilancio_view_model.dart';
import 'package:jamb/ui/contabilita/widgets/riquadro_bilancio.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';

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

    return SchermataBilancio(
      titolo: 'Bilancio',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      anni: viewModel.anni,
      annoScelto: viewModel.annoScout,
      onAnno: viewModel.scegliAnno,
      contenuti: [
        RiepilogoBilancio(viewModel.bilancio),
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
    );
  }
}
