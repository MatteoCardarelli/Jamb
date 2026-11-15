import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';
import 'package:jamb/ui/auth/view_model/login_view_model.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';
import 'package:jamb/ui/core/widgets/sfondo_paesaggio.dart';

const Color _blu = Color(0xFF1D2660);

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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Lo stesso paesaggio delle schermate dell'app, in basso: non sale
            // quando si apre la tastiera.
            const SfondoPaesaggio(altezza: 200),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Intestazione(),
                      const SizedBox(height: 36),
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
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration: jambDecorazioneCampo(
                          'La tua password',
                          icona: Icons.lock_outline_rounded,
                        ),
                        onSubmitted: (_) => _doLogin(context),
                      ),
                      Consumer<LoginViewModel>(
                        builder: (context, vm, _) {
                          if (vm.errorMessage == null) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              vm.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Il pulsante principale dei form dell'app; durante
                      // l'accesso è disattivato.
                      Consumer<LoginViewModel>(
                        builder: (context, vm, _) => JambBarraAzioni(
                          mostraIndietro: false,
                          etichetta: 'Accedi',
                          icona: Icons.login_rounded,
                          onPressed: vm.isLoading
                              ? null
                              : () => _doLogin(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

/// Logo, nome e una riga che dice a cosa serve l'app.
class _Intestazione extends StatelessWidget {
  const _Intestazione();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A1D2660),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset('assets/icons/app_icon.png'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Jamb',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: _blu,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ragazzi, appello, cassa, calendario e campo:\nil servizio dello staff, in un posto solo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
