import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';

/// Intestazione delle schermate di sezione: freccia per tornare indietro e
/// titolo, in cima al contenuto scorrevole.
class JambIntestazione extends StatelessWidget {
  final String titolo;

  const JambIntestazione({super.key, required this.titolo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BackActionButton(),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            titolo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
            ),
          ),
        ),
      ],
    );
  }
}
