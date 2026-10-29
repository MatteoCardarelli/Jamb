import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/ui/home/widgets/azioni_rapide_widget.dart';

void main() {
  // Nel collaudo un pulsante presente veniva preso per funzionante: le azioni
  // non ancora realizzate devono dirlo invece di non fare nulla.
  testWidgets('un\'azione non ancora disponibile lo segnala quando viene toccata', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: AzioniRapideWidget())),
    ));

    await tester.tap(find.text('Carica Doc'));
    await tester.pump();

    expect(find.text('Carica Doc sarà disponibile in una prossima versione.'), findsOneWidget);
  });
}
