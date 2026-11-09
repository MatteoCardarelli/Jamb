import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/pannello_progressione.dart';

void main() {
  test('immagineProgressione converte il nome nel file dell\'asset', () {
    expect(
      immagineProgressione('specialita', 'EsploratoreDelleAcque'),
      'assets/specialita/esploratore_delle_acque.jpg',
    );
  });

  group('AzioniProgressione', () {
    late int eliminazioni;

    Future<void> apriPannello(WidgetTester tester) async {
      eliminazioni = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => apriPannelloProgressione(
                context,
                (_) => PannelloProgressione(children: [
                  AzioniProgressione(
                    titoloConferma: 'Elimina Specialità',
                    nome: 'Nuotatore',
                    onElimina: () => eliminazioni++,
                    onSalva: () {},
                  ),
                ]),
              ),
              child: const Text('apri'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ELIMINA'));
      await tester.pumpAndSettle();
    }

    testWidgets('annullando non elimina e il pannello resta aperto', (tester) async {
      await apriPannello(tester);
      await tester.tap(find.text('ANNULLA'));
      await tester.pumpAndSettle();

      expect(eliminazioni, 0);
      expect(find.text('SALVA'), findsOneWidget);
    });

    testWidgets('confermando elimina una volta e chiude il pannello', (tester) async {
      await apriPannello(tester);
      await tester.tap(find.text('ELIMINA').last);
      await tester.pumpAndSettle();

      expect(eliminazioni, 1);
      expect(find.text('SALVA'), findsNothing);
    });
  });

  testWidgets('la data compare solo a conseguimento raggiunto', (tester) async {
    Widget data(bool visibile) => MaterialApp(
          home: Scaffold(
            body: DataConseguimento(
              visibile: visibile,
              etichetta: 'DATA',
              data: DateTime(2026, 3, 5),
              onCambia: (_) {},
            ),
          ),
        );

    await tester.pumpWidget(data(false));
    expect(find.text('05/03/2026'), findsNothing);

    await tester.pumpWidget(data(true));
    await tester.pumpAndSettle();
    expect(find.text('05/03/2026'), findsOneWidget);
  });
}
