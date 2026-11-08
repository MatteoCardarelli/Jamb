import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/ruolo_display.dart';
import 'package:jamb/domain/entities/formazione.dart';
import 'package:jamb/domain/repositories/formazione_repository.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_schermata_elenco.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/profilo/view_model/profilo_view_model.dart';
import 'package:jamb/ui/profilo/widgets/sezioni_formazione.dart';

/// Iter formativo di tutti i capi del gruppo (US29), per il Capo Gruppo.
class FormazioneCocaScreen extends StatelessWidget {
  const FormazioneCocaScreen({super.key});

  /// Apre la formazione della Co.Ca.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FormazioneCocaScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          FormazioneCocaViewModel(context.read<IFormazioneRepository>()),
      child: const _FormazioneCocaView(),
    );
  }
}

class _FormazioneCocaView extends StatelessWidget {
  const _FormazioneCocaView();

  void _apriCapo(
    BuildContext context,
    FormazioneCocaViewModel viewModel,
    CapoFormazione capo,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _DettaglioCapo(capo: capo, progetto: viewModel.progettoDi(capo)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FormazioneCocaViewModel>();

    return JambSchermataElenco(
      titolo: 'Formazione della Co.Ca.',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      children: [
        JambRiquadro(
          children: [
            if (viewModel.capi.isEmpty)
              const JambTestoVuoto('Nessun capo nel gruppo.'),
            for (final capo in viewModel.capi)
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => _apriCapo(context, viewModel, capo),
                title: Text(
                  capo.nome,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${ruoloLabel(capo.ruolo)} · ${capo.tappe.length} su ${TappaFormativa.values.length}'
                  '${switch (prossimaTappa(capo.tappe)) {
                    final t? => ' · prossima: ${t.valoreDb == 'NOMINA' ? 'Nomina' : t.valoreDb}',
                    null => ' · iter concluso',
                  }}',
                  style: const TextStyle(fontFamily: 'Lexend', fontSize: 13),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Iter e Progetto di un capo, in sola lettura.
class _DettaglioCapo extends StatelessWidget {
  final CapoFormazione capo;
  final Future<ProgettoCapo> progetto;

  const _DettaglioCapo({required this.capo, required this.progetto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: JambAppBar(titolo: capo.nome),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            RiquadroIter(tappe: capo.tappe),
            const SizedBox(height: 16),
            FutureBuilder<ProgettoCapo>(
              future: progetto,
              builder: (context, stato) {
                if (stato.hasError) {
                  return const JambTestoVuoto(
                    'Progetto del Capo non disponibile.',
                  );
                }
                if (!stato.hasData) return const JambCaricamentoPiccolo();
                return RiquadroProgetto(progetto: stato.data!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
