import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Avvia la chiamata a [numero] con l'app telefono del sistema.
Future<void> chiamaNumero(String numero) async {
  final uri = Uri(scheme: 'tel', path: numero.replaceAll(RegExp(r'\s+'), ''));
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint("Errore durante l'avvio della chiamata: $e");
  }
}

/// Riga di una rubrica: chi è, il numero e il pulsante per chiamare. Con
/// [onElimina] offre anche di toglierlo.
class JambRigaContatto extends StatelessWidget {
  final String etichetta;
  final String telefono;
  final VoidCallback? onElimina;

  const JambRigaContatto({
    super.key,
    required this.etichetta,
    required this.telefono,
    this.onElimina,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etichetta.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                telefono,
                style: const TextStyle(
                  color: Color(0xFF1D2660),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),
        if (onElimina != null)
          IconButton(
            tooltip: 'Elimina contatto',
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
            onPressed: onElimina,
          ),
        Semantics(
          button: true,
          label: 'Chiama $etichetta',
          child: GestureDetector(
            onTap: () => chiamaNumero(telefono),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Color(0xFF1D2660),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
