import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jamb/domain/entities/scout.dart'; // Importa entità di dominio

/// Widget che visualizza la lista dei contatti di emergenza dello scout.
/// Utilizza l'entità di dominio [ContattoEmergenza] (Shared Model).
class ContattiEmergenzaWidget extends StatelessWidget {
  /// Lista dei contatti da visualizzare
  final List<ContattoEmergenza> contatti;

  const ContattiEmergenzaWidget({super.key, required this.contatti});

  /// Avvia l'applicazione telefono del sistema operativo
  Future<void> _makeCall(String phoneNumber) async {
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
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
                  color: Color(0xFF94A3B8),
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
                  color: Color(0xFF1D2660),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),
        
        GestureDetector(
          onTap: () => _makeCall(contatto.telefono),
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
      ],
    );
  }
}
