import 'package:flutter/material.dart';

/// Messaggio al posto di un elenco vuoto (es. "Nessun avviso in bacheca.").
///
/// In linea è una riga grigia dentro una sezione o un riquadro; [centrato]
/// occupa il posto di una schermata intera, con un'[icona] facoltativa e un
/// [suggerimento] sotto (es. "Prova a cambiare i filtri").
class JambTestoVuoto extends StatelessWidget {
  final String testo;
  final IconData? icona;
  final String? suggerimento;
  final bool centrato;

  const JambTestoVuoto(
    this.testo, {
    super.key,
    this.icona,
    this.suggerimento,
    this.centrato = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!centrato) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          testo,
          style: const TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Lexend', fontSize: 14),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icona != null) ...[
              Icon(icona, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 16),
            ],
            Text(
              testo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (suggerimento != null) ...[
              const SizedBox(height: 8),
              Text(
                suggerimento!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontFamily: 'Lexend'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Indicatore di caricamento piccolo per una parte di schermata (es. le
/// categorie di un form), che non blocca il resto.
class JambCaricamentoPiccolo extends StatelessWidget {
  const JambCaricamentoPiccolo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
