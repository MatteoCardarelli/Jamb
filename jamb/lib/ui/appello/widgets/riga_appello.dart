import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/ui/appello/widgets/stato_presenza_ui.dart';
import 'package:jamb/ui/core/stile.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';

/// Riga dell'appello: nome del ragazzo e un tocco per segnarlo presente,
/// assente o giustificato. Senza [stato] il ragazzo è ancora da segnare.
class RigaAppello extends StatelessWidget {
  final String nome;
  final StatoPresenza? stato;
  final ValueChanged<StatoPresenza> onCambia;

  const RigaAppello({
    super.key,
    required this.nome,
    required this.stato,
    required this.onCambia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: bordoRiquadro,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nome,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in StatoPresenza.values)
                JambChipFiltro(
                  etichetta: s.etichetta,
                  selezionato: stato == s,
                  alert: s == StatoPresenza.assente,
                  onTap: () => onCambia(s),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
