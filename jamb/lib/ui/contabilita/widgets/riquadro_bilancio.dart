import 'package:flutter/material.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/stile.dart';

/// Riga di un bilancio: una voce e il suo importo in centesimi.
class RigaImporto extends StatelessWidget {
  final String voce;
  final int centesimi;
  final bool forte;

  const RigaImporto(this.voce, this.centesimi, {super.key, this.forte = false});

  @override
  Widget build(BuildContext context) {
    final stile = TextStyle(
      fontFamily: 'Lexend',
      fontSize: forte ? 15 : 14,
      fontWeight: forte ? FontWeight.w800 : FontWeight.w500,
      color: const Color(0xFF1E293B),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(voce, style: stile)),
          Text('€ ${importoLeggibile(centesimi)}', style: stile),
        ],
      ),
    );
  }
}

/// Riquadro bianco di un bilancio, con un [titolo] e le sue righe.
class RiquadroBilancio extends StatelessWidget {
  final String titolo;
  final List<Widget> righe;

  const RiquadroBilancio({super.key, required this.titolo, required this.righe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: bordoRiquadro,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titolo,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1D2660),
            ),
          ),
          const SizedBox(height: 8),
          ...righe,
        ],
      ),
    );
  }
}
