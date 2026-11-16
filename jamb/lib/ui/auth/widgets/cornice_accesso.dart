import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/sfondo_paesaggio.dart';

const Color _blu = Color(0xFF1D2660);

/// Schermate d'accesso (password, codice della verifica in due passaggi):
/// logo, nome, una riga di [sottotitolo], i [children] e lo stesso paesaggio
/// delle altre schermate in fondo.
class CorniceAccesso extends StatelessWidget {
  final String sottotitolo;
  final List<Widget> children;

  const CorniceAccesso({
    super.key,
    required this.sottotitolo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _Intestazione(sottotitolo),
                    const SizedBox(height: 36),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Messaggio d'errore sotto i campi di una schermata d'accesso (nessuno se
/// [messaggio] è `null`).
class ErroreAccesso extends StatelessWidget {
  final String? messaggio;

  const ErroreAccesso(this.messaggio, {super.key});

  @override
  Widget build(BuildContext context) {
    final testo = messaggio;
    if (testo == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        testo,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Logo, nome e una riga sotto.
class _Intestazione extends StatelessWidget {
  final String sottotitolo;

  const _Intestazione(this.sottotitolo);

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
        Text(
          sottotitolo,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
