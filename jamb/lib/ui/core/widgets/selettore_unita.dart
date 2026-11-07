import 'package:flutter/material.dart';
import 'package:jamb/core/ruolo_display.dart';
import 'package:jamb/core/unita_attiva.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';

/// Elenco delle unità in cui l'utente può operare, con il ruolo in ciascuna
/// e un segno di spunta su quella attiva. Toccandone un'altra la si sceglie.
class SelettoreUnita extends StatelessWidget {
  final List<UnitaDisponibile> unita;
  final String? attiva;
  final ValueChanged<String> onScegli;

  const SelettoreUnita({
    super.key,
    required this.unita,
    required this.attiva,
    required this.onScegli,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const JambEtichettaCampo('Unità'),
        for (final u in unita)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              u.id == attiva ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: u.id == attiva ? const Color(0xFF1D2660) : const Color(0xFFCBD5E1),
            ),
            title: Text(
              u.nome,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: u.id == attiva ? FontWeight.w800 : FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              u.ruolo == null ? ruoloLabel('CAPO_GRUPPO') : ruoloLabel(u.ruolo!),
              style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF64748B)),
            ),
            onTap: u.id == attiva ? null : () => onScegli(u.id),
          ),
      ],
    );
  }
}
