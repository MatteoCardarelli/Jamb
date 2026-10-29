import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/avviso.dart';
import 'package:jamb/ui/bacheca/view_model/bacheca_view_model.dart';
import 'package:jamb/ui/core/stile.dart';

/// Riquadro di un avviso nell'elenco della bacheca: oggetto, anteprima del
/// testo, destinatari e data. Gli avvisi non letti hanno un pallino blu e
/// l'oggetto in grassetto.
class AvvisoCard extends StatelessWidget {
  final Avviso avviso;
  final VoidCallback onTap;

  const AvvisoCard({super.key, required this.avviso, required this.onTap});

  static const Color _blu = Color(0xFF1D2660);
  static const Color _grigio = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: bordoRiquadro,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!avviso.letto) ...[
                      Semantics(
                        label: 'Non letto',
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _blu,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        avviso.titolo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: avviso.letto ? FontWeight.w600 : FontWeight.w900,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      BachecaViewModel.dataBreve(avviso.dataPubblicazione),
                      style: const TextStyle(color: _grigio, fontSize: 12, fontFamily: 'Lexend'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  avviso.contenuto,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontFamily: 'Lexend'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      avviso.perTuttaLUnita ? Icons.groups_rounded : Icons.shield_rounded,
                      size: 14,
                      color: _grigio,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        [
                          avviso.squadriglia ?? "Tutta l'unità",
                          if (avviso.autore.isNotEmpty) avviso.autore,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _grigio,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
