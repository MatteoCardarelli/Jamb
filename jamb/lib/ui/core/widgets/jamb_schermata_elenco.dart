import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';

/// Schermata di dettaglio con barra, stati di caricamento ed errore e un
/// contenuto scorrevole (es. bilanci, sottogruppi, PEG, campo).
class JambSchermataElenco extends StatelessWidget {
  final String titolo;
  final bool caricamento;

  /// Messaggio da mostrare al posto dei [children] (`null` se non c'è errore).
  final String? errore;
  final VoidCallback onRiprova;
  final List<Widget> children;

  const JambSchermataElenco({
    super.key,
    required this.titolo,
    required this.caricamento,
    required this.errore,
    required this.onRiprova,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final messaggio = errore;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: JambAppBar(titolo: titolo),
      body: SafeArea(
        top: false,
        child: caricamento
            ? const Center(child: CircularProgressIndicator())
            : messaggio != null
            ? JambStatoErrore(messaggio: messaggio, onRiprova: onRiprova)
            : ListView(padding: const EdgeInsets.all(20), children: children),
      ),
    );
  }
}
