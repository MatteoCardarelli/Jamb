import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';

/// Apre un menu con [quante] voci su uno schermo alto [altezza] punti;
/// restituisce l'elenco (che si riempie dopo) delle voci toccate.
Future<List<String>> _apriMenu(
  WidgetTester tester, {
  required int quante,
  required double altezza,
}) async {
  tester.view.physicalSize = Size(390, altezza);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final toccate = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => mostraMenuJamb(
                context,
                titolo: 'Chiara Ferretti',
                sottotitolo: 'Capo Gruppo',
                voci: (_) => [
                  for (var i = 1; i <= quante; i++)
                    JambVoceMenu(
                      icona: Icons.circle_outlined,
                      etichetta: 'Voce $i',
                      onTap: () => toccate.add('Voce $i'),
                    ),
                ],
              ),
              child: const Text('Apri'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Apri'));
  await tester.pumpAndSettle();
  return toccate;
}

void main() {
  testWidgets("con molte voci il menu scorre e l'ultima si raggiunge", (
    tester,
  ) async {
    final toccate = await _apriMenu(tester, quante: 15, altezza: 640);

    // Nessun «bottom overflowed»: il menu non sfora lo schermo.
    expect(tester.takeException(), isNull);
    expect(find.text('Chiara Ferretti'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Voce 15'),
      120,
      scrollable: find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Voce 15'));
    await tester.pumpAndSettle();

    expect(toccate, ['Voce 15']);
  });

  testWidgets('con poche voci il menu resta alto quanto il contenuto', (
    tester,
  ) async {
    await _apriMenu(tester, quante: 3, altezza: 800);

    expect(tester.takeException(), isNull);
    final altezzaMenu = tester.getSize(find.byType(BottomSheet)).height;
    expect(altezzaMenu, lessThan(800 * altezzaMassimaMenu));
  });
}
