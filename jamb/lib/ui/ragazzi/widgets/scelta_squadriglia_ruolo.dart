import 'package:flutter/material.dart';
import 'package:jamb/core/ruolo_display.dart';
import 'package:jamb/domain/entities/nuovo_ragazzo.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';

/// Scelta della squadriglia (o sestiglia) e del ruolo in squadriglia di un
/// ragazzo: si usa nella modifica del ragazzo e quando lo si aggiunge.
///
/// Senza [squadriglie] (es. nel Clan) la prima parte non compare.
class SceltaSquadrigliaRuolo extends StatelessWidget {
  final List<String> squadriglie;

  /// Squadriglia scelta; vuota se nessuna.
  final String squadriglia;

  /// Uno tra [ruoliRagazzo].
  final String ruolo;

  final ValueChanged<String> onSquadriglia;
  final ValueChanged<String> onRuolo;

  const SceltaSquadrigliaRuolo({
    super.key,
    required this.squadriglie,
    required this.squadriglia,
    required this.ruolo,
    required this.onSquadriglia,
    required this.onRuolo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (squadriglie.isNotEmpty) ...[
          const JambEtichettaCampo('Squadriglia'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sq in squadriglie)
                JambChipFiltro(
                  etichetta: sq,
                  icona: Icons.shield_rounded,
                  selezionato: squadriglia.toLowerCase() == sq.toLowerCase(),
                  onTap: () => onSquadriglia(sq),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        const JambEtichettaCampo('Ruolo in squadriglia'),
        for (final r in ruoliRagazzo)
          _VoceRuolo(
            etichetta: ruoloLabel(r),
            selezionato: ruolo == r,
            onTap: () => onRuolo(r),
          ),
      ],
    );
  }
}

/// Riga di un ruolo, con il segno di spunta su quello scelto.
class _VoceRuolo extends StatelessWidget {
  final String etichetta;
  final bool selezionato;
  final VoidCallback onTap;

  const _VoceRuolo({
    required this.etichetta,
    required this.selezionato,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selezionato
              ? const Color(0xFFEEF2FF)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selezionato
                ? const Color(0xFF1D2660)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              etichetta,
              style: TextStyle(
                color: selezionato
                    ? const Color(0xFF1D2660)
                    : const Color(0xFF64748B),
                fontWeight: selezionato ? FontWeight.w800 : FontWeight.w500,
                fontFamily: 'Lexend',
              ),
            ),
            if (selezionato)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1D2660),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
