import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/ui/core/widgets/cornice_schermo_largo.dart';

/// App minima con la cornice e uno schermo largo [larghezza] punti; restituisce
/// la larghezza che le schermate leggono da `MediaQuery`.
Future<double> _larghezzaVista(WidgetTester tester, double larghezza) async {
  tester.view.physicalSize = Size(larghezza, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late double letta;
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => CorniceSchermoLargo(child: child!),
      home: Builder(
        builder: (context) {
          letta = MediaQuery.of(context).size.width;
          return const Scaffold(body: SizedBox.expand(key: Key('contenuto')));
        },
      ),
    ),
  );
  return letta;
}

void main() {
  testWidgets('sul computer le schermate restano larghe come un telefono', (
    tester,
  ) async {
    final letta = await _larghezzaVista(tester, 1400);

    expect(letta, larghezzaMassimaApp);
    expect(
      tester.getSize(find.byKey(const Key('contenuto'))).width,
      larghezzaMassimaApp,
    );
  });

  testWidgets('su un telefono la cornice non cambia nulla', (tester) async {
    final letta = await _larghezzaVista(tester, 390);

    expect(letta, 390);
    expect(tester.getSize(find.byKey(const Key('contenuto'))).width, 390);
  });
}
