import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/domain/repositories/presenza_repository.dart';
import 'package:jamb/ui/appello/widgets/stato_presenza_ui.dart';
import 'package:jamb/ui/core/widgets/jamb_errore_in_linea.dart';
import 'package:jamb/ui/dettaglio_ragazzo/view_model/presenze_ragazzo_view_model.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';

/// Riquadro delle presenze nel dettaglio ragazzo: riepilogo, ultime
/// presenze e segnalazione delle assenze ripetute.
class PresenzeWidget extends StatelessWidget {
  final String ragazzoId;

  const PresenzeWidget({super.key, required this.ragazzoId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          PresenzeRagazzoViewModel(ragazzoId, context.read<IPresenzaRepository>()),
      child: const _PresenzeView(),
    );
  }
}

class _PresenzeView extends StatelessWidget {
  const _PresenzeView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PresenzeRagazzoViewModel>();

    return JambRiquadro(
      titolo: "Presenze",
      children: [
        if (viewModel.isLoading && viewModel.ultime.isEmpty)
          const JambCaricamentoPiccolo()
        else if (viewModel.haErrore)
          JambErroreInLinea(
            messaggio: 'Presenze non disponibili: ${viewModel.errore}',
            onRiprova: viewModel.ricarica,
          )
        else if (viewModel.ultime.isEmpty)
          const JambTestoVuoto("Nessun appello registrato.")
        else ...[
          if (viewModel.assenzeRipetute) _AvvisoAssenze(viewModel.serieAssenze),
          if (viewModel.riepilogo.isNotEmpty)
            Text(
              viewModel.riepilogo,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 12),
          for (final presenza in viewModel.ultime) _RigaPresenza(presenza),
        ],
      ],
    );
  }
}

/// Segnalazione delle assenze consecutive non giustificate.
class _AvvisoAssenze extends StatelessWidget {
  final int assenze;

  const _AvvisoAssenze(this.assenze);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$assenze assenze consecutive non giustificate',
              style: const TextStyle(
                color: Color(0xFFE11D48),
                fontWeight: FontWeight.w700,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una presenza dello storico: data, evento e stato.
class _RigaPresenza extends StatelessWidget {
  final PresenzaRagazzo presenza;

  const _RigaPresenza(this.presenza);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              DateFormat('dd/MM/yy').format(presenza.dataEvento),
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontFamily: 'Lexend'),
            ),
          ),
          Expanded(
            child: Text(
              presenza.titoloEvento,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontFamily: 'Lexend'),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            presenza.stato.etichetta,
            style: TextStyle(
              color: presenza.stato.colore,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}
