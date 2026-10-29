import 'package:flutter/material.dart';

/// Chip a pillola per filtri e scelte singole (es. squadriglia, destinatari):
/// blu pieno quando è [selezionato], bianco con bordo altrimenti.
///
/// Con [alert] usa i toni rossi delle segnalazioni mediche; con [menu]
/// mostra la freccia di un menu a tendina.
class JambChipFiltro extends StatelessWidget {
  final String etichetta;
  final bool selezionato;
  final VoidCallback? onTap;
  final IconData? icona;
  final bool alert;
  final bool menu;

  const JambChipFiltro({
    super.key,
    required this.etichetta,
    required this.selezionato,
    this.onTap,
    this.icona,
    this.alert = false,
    this.menu = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color sfondo;
    final Color bordo;
    final Color testo;

    if (selezionato && alert) {
      sfondo = const Color(0xFFE11D48); // Rosso Alert Attivo
      bordo = const Color(0xFFE11D48);
      testo = Colors.white;
    } else if (selezionato) {
      sfondo = const Color(0xFF1D2660); // Blu Jamb Attivo
      bordo = const Color(0xFF1D2660);
      testo = Colors.white;
    } else if (alert) {
      sfondo = const Color(0xFFFFF1F2); // Rosa Alert Inattivo
      bordo = const Color(0xFFFECDD3);
      testo = const Color(0xFFE11D48);
    } else {
      sfondo = Colors.white;
      bordo = const Color(0xFFE2E8F0);
      testo = const Color(0xFF64748B);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sfondo,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bordo, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icona != null) ...[
              Icon(icona, size: 16, color: testo),
              const SizedBox(width: 6),
            ],
            Text(
              etichetta,
              style: TextStyle(
                color: testo,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lexend',
              ),
            ),
            if (menu) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: testo),
            ],
          ],
        ),
      ),
    );
  }
}
