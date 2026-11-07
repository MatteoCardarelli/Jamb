import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/unita_attiva.dart';
import 'package:jamb/ui/core/widgets/selettore_unita.dart';

void main() {
  const unita = [
    UnitaDisponibile(id: 'lc', nome: 'Branco Seeonee', ruolo: 'CAPO_UNITA'),
    UnitaDisponibile(id: 'eg', nome: 'Reparto Velino'), // Capo Gruppo, senza membership
  ];

  Future<List<String>> mostra(WidgetTester tester) async {
    final scelte = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SelettoreUnita(unita: unita, attiva: 'lc', onScegli: scelte.add),
      ),
    ));
    return scelte;
  }

  group('SelettoreUnita', () {
    testWidgets('mostra le unità con il ruolo in ciascuna', (tester) async {
      await mostra(tester);

      expect(find.text('Capo Unità'), findsOneWidget);
      // Senza membership il Capo Gruppo vede l'unità con il suo ruolo di gruppo.
      expect(find.text('Capo Gruppo'), findsOneWidget);
    });

    testWidgets("toccare un'altra unità la sceglie, quella attiva no", (tester) async {
      final scelte = await mostra(tester);

      await tester.tap(find.text('Branco Seeonee'));
      await tester.tap(find.text('Reparto Velino'));

      expect(scelte, ['eg']);
    });
  });
}
