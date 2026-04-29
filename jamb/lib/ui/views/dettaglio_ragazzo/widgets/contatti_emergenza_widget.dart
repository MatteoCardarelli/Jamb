import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContattoEmergenza {
  String nome;
  String telefono;

  ContattoEmergenza({required this.nome, required this.telefono});
}

class ContattiEmergenzaWidget extends StatelessWidget {
  final List<ContattoEmergenza> contatti;

  const ContattiEmergenzaWidget({super.key, required this.contatti});

  Future<void> _makeCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Errore avvio chiamata: $e");
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
              padding: EdgeInsets.only(top: 12),
              child: Text(
                "Nessun contatto aggiunto.",
                style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Lexend'),
              ),
            )
          else
            ...List.generate(contatti.length, (i) => Column(
              children: [
                if (i > 0) const Divider(color: Color(0xFFF1F5F9), height: 32),
                if (i == 0) const SizedBox(height: 24),
                _buildContactRow(contatti[i]),
              ],
            )),
        ],
      ),
    );
  }

  Widget _buildContactRow(ContattoEmergenza contatto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contatto.nome.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contatto.telefono,
              style: const TextStyle(
                color: Color(0xFF00005C),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _makeCall(contatto.telefono),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF00005C),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
