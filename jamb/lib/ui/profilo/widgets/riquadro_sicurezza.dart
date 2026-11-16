import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_errore_in_linea.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/profilo/view_model/sicurezza_view_model.dart';
import 'package:jamb/ui/profilo/widgets/attiva_due_fattori_screen.dart';

const _testo = TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.4);

/// Sezione «Sicurezza» del profilo: attivare o disattivare la verifica in
/// due passaggi. Legge [SicurezzaViewModel] dal contesto.
class RiquadroSicurezza extends StatelessWidget {
  const RiquadroSicurezza({super.key});

  Future<void> _attiva(BuildContext context, SicurezzaViewModel vm) async {
    final messenger = ScaffoldMessenger.of(context);
    final attivata = await AttivaDueFattoriScreen.apri(context);
    if (attivata != true) return;
    await vm.carica();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Verifica in due passaggi attiva: al prossimo accesso ti chiederemo il codice.',
        ),
      ),
    );
  }

  Future<void> _disattiva(BuildContext context, SicurezzaViewModel vm) async {
    final conferma = await JambDialogs.conferma(
      context,
      titolo: 'Disattivare la verifica?',
      messaggio:
          'Dal prossimo accesso basterà la password. Potrai riattivarla quando vuoi.',
      etichetta: 'DISATTIVA',
    );
    if (!conferma || !context.mounted) return;
    await eseguiConFeedback(context, vm.disattiva);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SicurezzaViewModel>();
    return JambRiquadro(
      titolo: 'Sicurezza',
      children: [
        if (vm.isLoading)
          const JambCaricamentoPiccolo()
        else if (vm.haErrore)
          JambErroreInLinea(
            messaggio: 'Stato non disponibile: ${vm.errore}',
            onRiprova: vm.carica,
          )
        else if (vm.dueFattori) ...[
          const Text(
            'Verifica in due passaggi attiva: a ogni accesso, dopo la '
            'password, Jamb chiede il codice della tua app di autenticazione.',
            style: _testo,
          ),
          const SizedBox(height: 12),
          JambPulsanteSecondario(
            icona: Icons.lock_open_rounded,
            etichetta: 'Disattiva la verifica in due passaggi',
            onTap: () => _disattiva(context, vm),
          ),
        ] else ...[
          const Text(
            'Proteggi i dati dei ragazzi: con la verifica in due passaggi, '
            'chi scopre la tua password non entra senza il tuo telefono.',
            style: _testo,
          ),
          const SizedBox(height: 12),
          JambPulsanteSecondario(
            icona: Icons.verified_user_outlined,
            etichetta: 'Attiva la verifica in due passaggi',
            onTap: () => _attiva(context, vm),
          ),
        ],
      ],
    );
  }
}
