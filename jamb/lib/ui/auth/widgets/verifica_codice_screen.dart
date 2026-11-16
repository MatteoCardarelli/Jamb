import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';
import 'package:jamb/ui/auth/view_model/verifica_codice_view_model.dart';
import 'package:jamb/ui/auth/widgets/campo_codice.dart';
import 'package:jamb/ui/auth/widgets/cornice_accesso.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';

/// Secondo passaggio dell'accesso, per chi ha attivato la verifica in due
/// passaggi: il codice di 6 cifre dell'app di autenticazione.
class VerificaCodiceScreen extends StatefulWidget {
  const VerificaCodiceScreen({super.key});

  @override
  State<VerificaCodiceScreen> createState() => _VerificaCodiceScreenState();
}

class _VerificaCodiceScreenState extends State<VerificaCodiceScreen> {
  final _codice = TextEditingController();

  @override
  void dispose() {
    _codice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => VerificaCodiceViewModel(ctx.read<IAuthRepository>()),
      child: Consumer<VerificaCodiceViewModel>(
        builder: (context, vm, _) => CorniceAccesso(
          sottotitolo:
              'Hai attivato la verifica in due passaggi.\nScrivi il codice che vedi ora nella tua app di autenticazione.',
          children: [
            const JambEtichettaCampo('Codice'),
            CampoCodice(
              controller: _codice,
              autofocus: true,
              onSubmitted: (testo) => vm.verifica(testo),
            ),
            ErroreAccesso(vm.errorMessage),
            const SizedBox(height: 24),
            JambBarraAzioni(
              mostraIndietro: false,
              etichetta: 'Verifica',
              icona: Icons.verified_user_outlined,
              onPressed: vm.isLoading ? null : () => vm.verifica(_codice.text),
            ),
            const SizedBox(height: 8),
            // Per chi non ha con sé il telefono, o ha sbagliato account.
            TextButton(
              onPressed: () => context.read<SessionService>().logout(),
              child: const Text('Esci e accedi con un altro account'),
            ),
          ],
        ),
      ),
    );
  }
}
