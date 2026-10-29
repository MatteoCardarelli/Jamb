import 'package:flutter/material.dart';

/// Errore di caricamento di una parte secondaria di un form (es. le opzioni
/// di una scelta), con «Riprova»: il resto del form resta utilizzabile.
class JambErroreInLinea extends StatelessWidget {
  final String messaggio;
  final VoidCallback onRiprova;

  const JambErroreInLinea({
    super.key,
    required this.messaggio,
    required this.onRiprova,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              messaggio,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          TextButton(onPressed: onRiprova, child: const Text('Riprova')),
        ],
      ),
    );
  }
}
