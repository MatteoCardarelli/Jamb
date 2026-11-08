import 'package:flutter/material.dart';

/// Riquadro bianco delle sezioni di una schermata (dettaglio ragazzo, bilanci,
/// sottogruppi), con il [titolo] della sezione se presente.
class JambRiquadro extends StatelessWidget {
  final String? titolo;
  final List<Widget> children;

  const JambRiquadro({super.key, this.titolo, required this.children});

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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titolo != null) ...[
            Text(
              titolo!,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }
}
