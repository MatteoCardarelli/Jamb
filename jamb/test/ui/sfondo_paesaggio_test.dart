import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/ui/core/widgets/sfondo_paesaggio.dart';

/// Schermata minima con lo sfondo alto 200, su uno schermo [larghezza]×[altezza].
Future<void> _mostra(
  WidgetTester tester,
  double larghezza,
  double altezza,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(larghezza, altezza);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: Stack(children: [SfondoPaesaggio(altezza: 200)])),
    ),
  );
}

double _cimaSfondo(WidgetTester tester) =>
    tester.getTopLeft(find.byType(Image)).dy;

void main() {
  testWidgets(
    'quando la tastiera accorcia la pagina (browser del telefono) lo sfondo non sale',
    (tester) async {
      addTearDown(tester.view.reset);
      await _mostra(tester, 390, 800);
      expect(_cimaSfondo(tester), 600);

      // Si apre la tastiera: nel browser la pagina diventa alta 500.
      await _mostra(tester, 390, 500);
      expect(_cimaSfondo(tester), 600);

      // Si chiude: torna dov'era.
      await _mostra(tester, 390, 800);
      expect(_cimaSfondo(tester), 600);
    },
  );

  testWidgets('ruotando lo schermo si riaggancia al nuovo fondo', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await _mostra(tester, 390, 800);
    expect(_cimaSfondo(tester), 600);

    await _mostra(tester, 800, 390);
    expect(_cimaSfondo(tester), 190);
  });
}
