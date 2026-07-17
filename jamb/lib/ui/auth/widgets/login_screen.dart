import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/auth/view_model/login_view_model.dart';

/// Schermata di login: form email/password per l'autenticazione a Supabase.
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.hiking, size: 64, color: Color(0xFF003366)),
                const SizedBox(height: 8),
                Text(
                  'JAMB',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  onSubmitted: (_) => _doLogin(context),
                ),
                Consumer<LoginViewModel>(
                  builder: (context, vm, _) {
                    if (vm.errorMessage == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        vm.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Consumer<LoginViewModel>(
                  builder: (context, vm, _) {
                    return FilledButton(
                      onPressed: vm.isLoading ? null : () => _doLogin(context),
                      child: vm.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Accedi'),
                    );
                  },
                ),
              ],
            ),
          ),
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