import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';
import 'package:jamb/ui/auth/view_model/login_view_model.dart';
import 'package:jamb/ui/auth/widgets/cornice_accesso.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';

/// Schermata di accesso con email e password.
///
/// È la prima cosa che vede chi apre Jamb: logo, nome, a cosa serve, e lo
/// stesso paesaggio delle altre schermate in fondo.
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => LoginViewModel(ctx.read<IAuthRepository>()),
      child: CorniceAccesso(
        sottotitolo:
            'Ragazzi, appello, cassa, calendario e campo:\nil servizio dello staff, in un posto solo.',
        children: [
          const JambEtichettaCampo('Email'),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            decoration: jambDecorazioneCampo(
              'nome@esempio.it',
              icona: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 16),
          const JambEtichettaCampo('Password'),
          Builder(
            builder: (context) => TextField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: jambDecorazioneCampo(
                'La tua password',
                icona: Icons.lock_outline_rounded,
              ),
              onSubmitted: (_) => _doLogin(context),
            ),
          ),
          Consumer<LoginViewModel>(
            builder: (context, vm, _) => ErroreAccesso(vm.errorMessage),
          ),
          const SizedBox(height: 24),
          // Il pulsante principale dei form dell'app; durante l'accesso è
          // disattivato.
          Consumer<LoginViewModel>(
            builder: (context, vm, _) => JambBarraAzioni(
              mostraIndietro: false,
              etichetta: 'Accedi',
              icona: Icons.login_rounded,
              onPressed: vm.isLoading ? null : () => _doLogin(context),
            ),
          ),
        ],
      ),
    );
  }

  void _doLogin(BuildContext context) {
    context.read<LoginViewModel>().login(
      _emailController.text,
      _passwordController.text,
    );
  }
}
