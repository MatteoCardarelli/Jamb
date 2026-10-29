import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';

/// Barra delle schermate di dettaglio: freccia per tornare indietro, titolo
/// centrato ed eventuali [azioni] (es. modifica, elimina).
class JambAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titolo;
  final List<Widget> azioni;
  final Color coloreSfondo;

  const JambAppBar({
    super.key,
    required this.titolo,
    this.azioni = const [],
    this.coloreSfondo = Colors.white,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: coloreSfondo,
      elevation: 0,
      leadingWidth: 80,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: BackActionButton(),
      ),
      title: Text(
        titolo,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
          fontFamily: 'Lexend',
        ),
      ),
      centerTitle: true,
      actions: azioni,
    );
  }
}
