import 'package:flutter/material.dart';

/// Apre un menu dal basso con [titolo], un eventuale [sottotitolo] e le
/// [voci] costruite con il context del menu (per chiuderlo con `pop`).
Future<void> mostraMenuJamb(
  BuildContext context, {
  required String titolo,
  String sottotitolo = '',
  required List<Widget> Function(BuildContext menu) voci,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (menu) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titolo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D2660),
                fontFamily: 'Lexend',
              ),
            ),
            if (sottotitolo.isNotEmpty)
              Text(
                sottotitolo,
                style: const TextStyle(color: Color(0xFF64748B), fontFamily: 'Lexend'),
              ),
            const SizedBox(height: 16),
            ...voci(menu),
          ],
        ),
      ),
    ),
  );
}

/// Voce di un menu: chiude il menu e poi esegue [onTap]. Con [pericolosa]
/// (es. eliminare, uscire) è rossa.
class JambVoceMenu extends StatelessWidget {
  final IconData icona;
  final String etichetta;
  final VoidCallback onTap;
  final bool pericolosa;

  const JambVoceMenu({
    super.key,
    required this.icona,
    required this.etichetta,
    required this.onTap,
    this.pericolosa = false,
  });

  @override
  Widget build(BuildContext context) {
    final colore = pericolosa ? const Color(0xFFB91C1C) : const Color(0xFF1D2660);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icona, color: colore),
      title: Text(
        etichetta,
        style: TextStyle(
          color: pericolosa ? colore : const Color(0xFF1E293B),
          fontWeight: FontWeight.w700,
          fontFamily: 'Lexend',
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}
