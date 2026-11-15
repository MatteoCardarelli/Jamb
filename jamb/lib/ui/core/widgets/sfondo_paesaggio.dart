import 'package:flutter/material.dart';

/// Paesaggio di montagne in fondo alle schermate, alto [altezza]: va messo
/// come primo figlio di uno `Stack` che riempie lo schermo.
///
/// Resta agganciato al fondo dello schermo anche quando la tastiera riduce lo
/// spazio, invece di salire con lei. Nell'app la tastiera lascia invariata
/// l'altezza di `MediaQuery`; nel browser del telefono invece la riduce, quindi
/// si usa l'altezza più grande vista con la stessa larghezza (che cambia se si
/// ruota il telefono o si allarga la finestra).
class SfondoPaesaggio extends StatefulWidget {
  final double altezza;

  const SfondoPaesaggio({super.key, required this.altezza});

  @override
  State<SfondoPaesaggio> createState() => _SfondoPaesaggioState();
}

class _SfondoPaesaggioState extends State<SfondoPaesaggio> {
  double _larghezza = 0;
  double _altezzaSchermo = 0;

  @override
  Widget build(BuildContext context) {
    final schermo = MediaQuery.sizeOf(context);
    if (schermo.width != _larghezza || schermo.height > _altezzaSchermo) {
      _larghezza = schermo.width;
      _altezzaSchermo = schermo.height;
    }

    return Positioned(
      top: _altezzaSchermo - widget.altezza,
      left: 0,
      right: 0,
      height: widget.altezza,
      child: Image.asset(
        'assets/icons/sfondo.png',
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}
