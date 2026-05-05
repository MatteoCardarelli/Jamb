import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rappresenta un singolo contatto di emergenza (es. Genitore)
class ContattoEmergenza {
  String nome;
  String telefono;

  ContattoEmergenza({required this.nome, required this.telefono});
}

/// Widget che visualizza la lista dei contatti di emergenza dello scout.
/// Include la funzionalità di chiamata diretta tramite il tasto telefono.
class ContattiEmergenzaWidget extends StatelessWidget {
  /// Lista dei contatti da visualizzare
  final List<ContattoEmergenza> contatti;

  const ContattiEmergenzaWidget({super.key, required this.contatti});

  /// Avvia l'applicazione telefono del sistema operativo
  Future<void> _makeCall(String phoneNumber) async {
    // Rimuoviamo gli spazi per assicurarci che il numero sia valido per l'URI
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Errore durante l'avvio della chiamata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITOLO SEZIONE
          const Text(
            "Contatti di emergenza",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
            ),
          ),
          
          if (contatti.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                "Nessun contatto registrato.",
                style: TextStyle(
                  color: Color(0xFF94A3B8), 
                  fontFamily: 'Lexend',
                  fontSize: 14,
                ),
              ),
            )
          else
            ...List.generate(contatti.length, (index) {
              return Column(
                children: [
                  if (index > 0) 
                    const Divider(color: Color(0xFFF1F5F9), height: 32, thickness: 1.5),
                  if (index == 0) const SizedBox(height: 24),
                  _buildContactRow(contatti[index]),
                ],
              );
            }),
        ],
      ),
    );
  }

  /// Costruisce una riga contenente nome, numero e tasto di chiamata
  Widget _buildContactRow(ContattoEmergenza contatto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contatto.nome.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF94A3B8), // Slate 400
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                contatto.telefono,
                style: const TextStyle(
                  color: Color(0xFF1D2660), // Navy Blue
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),
        
        // TASTO CHIAMA (Circular Action Button)
        GestureDetector(
          onTap: () => _makeCall(contatto.telefono),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9), // Slate 100
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_rounded,
              color: Color(0xFF1D2660),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
