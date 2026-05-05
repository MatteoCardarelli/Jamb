import 'package:flutter/material.dart';

/// Intestazione della vista di dettaglio scout.
/// Visualizza il nome prominente, il chip della squadriglia, il ruolo e 
/// segnala visivamente eventuali alert medici critici.
class DettaglioRagazzoHeader extends StatelessWidget {
  /// Nome e cognome dello scout
  final String nome;
  /// Squadriglia di appartenenza
  final String squadriglia;
  /// Ruolo nella squadriglia (es. "C.S.")
  final String ruolo;
  /// Se true, mostra un'icona medica rossa di pericolo
  final bool hasAlert;
  /// Callback per l'apertura del menu di modifica
  final VoidCallback? onEdit;

  const DettaglioRagazzoHeader({
    super.key,
    required this.nome,
    required this.squadriglia,
    required this.ruolo,
    required this.hasAlert,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // RIGA 1: NOME, ALERT E TASTO EDIT
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D2660),
                        fontFamily: 'Lexend',
                        height: 1.1,
                      ),
                    ),
                  ),
                  if (hasAlert) ...[
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.medical_services_rounded, 
                      size: 26, 
                      color: Color(0xFFE11D48), // Alert Red
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8), size: 28),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // RIGA 2: SQUADRIGLIA E RUOLO
        Row(
          children: [
            // Chip Squadriglia
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5), // Orange 100
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                squadriglia.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFEA580C), // Orange 600
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Lexend',
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Testo Ruolo
            Text(
              ruolo,
              style: const TextStyle(
                color: Color(0xFF94A3B8), // Slate 400
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
