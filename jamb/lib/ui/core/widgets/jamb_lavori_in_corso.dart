import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';

/// Avviso al posto di una parte dell'app che si sta rifacendo e per ora non
/// si usa: meglio dirlo che mostrare una schermata non all'altezza.
class JambLavoriInCorso extends StatelessWidget {
  /// Riga sotto il titolo, per dire cosa arriverà.
  final String messaggio;

  const JambLavoriInCorso({
    super.key,
    this.messaggio = 'Stiamo rifacendo questa parte: sarà disponibile presto.',
  });

  @override
  Widget build(BuildContext context) {
    return JambTestoVuoto(
      'Lavori in corso',
      icona: Icons.construction_rounded,
      suggerimento: messaggio,
      centrato: true,
    );
  }
}
