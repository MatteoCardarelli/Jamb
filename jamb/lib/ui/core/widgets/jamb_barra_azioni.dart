import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';

/// Barra d'azione in fondo ai form a tutto schermo: freccia per tornare
/// indietro, eventuali [azioniSecondarie] e il pulsante principale.
///
/// Va posizionata dal chiamante (es. sopra la barra di navigazione in basso).
/// Con [onPressed] `null` il pulsante principale è disabilitato.
class JambBarraAzioni extends StatelessWidget {
  final String etichetta;
  final IconData icona;
  final VoidCallback? onPressed;
  final List<Widget> azioniSecondarie;

  const JambBarraAzioni({
    super.key,
    required this.etichetta,
    required this.icona,
    required this.onPressed,
    this.azioniSecondarie = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BackActionButton(),
        for (final azione in azioniSecondarie) ...[
          const SizedBox(width: 12),
          azione,
        ],
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2660),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icona, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      etichetta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Lexend',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
