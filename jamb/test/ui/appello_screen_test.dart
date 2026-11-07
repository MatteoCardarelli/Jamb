import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/domain/repositories/presenza_repository.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/appello/widgets/appello_screen.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_presenza_repository.dart';
import '../../testing/fakes/fake_scout_repository.dart';
import '../../testing/models/scout_di_test.dart';

final _evento = Evento(
  id: 'riunione',
  titolo: 'Riunione di reparto',
  dataInizio: DateTime(2026, 11, 7, 15),
  dataFine: DateTime(2026, 11, 7, 17),
  luogo: 'Sede',
  categorie: const ['Altro'],
  colorePrincipale: Colors.blue,
);

void main() {
  late FakePresenzaRepository presenze;

  /// Apre l'appello sopra una schermata iniziale, come dal dettaglio evento.
  Future<void> apriAppello(WidgetTester tester) async {
    presenze = FakePresenzaRepository();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IScoutRepository>(
          create: (_) => FakeScoutRepository([scoutDiTest('Andrea', 'Aquile')]),
        ),
        ChangeNotifierProvider<IPresenzaRepository>.value(value: presenze),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => AppelloScreen.apri(context, _evento),
              child: const Text('Apri'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
  }

  group('AppelloScreen', () {
    // Un appello di venti ragazzi perso per un tocco sulla freccia è il
    // caso che la conferma deve evitare.
    testWidgets('uscendo con presenze non salvate chiede conferma', (tester) async {
      await apriAppello(tester);
      await tester.tap(find.text('Presente'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Appello non salvato'), findsOneWidget);

      await tester.tap(find.text('ANNULLA'));
      await tester.pumpAndSettle();
      expect(find.text('Riunione di reparto'), findsOneWidget);
      expect(presenze.salvataggi, isEmpty);
    });

    testWidgets('senza modifiche esce subito', (tester) async {
      await apriAppello(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Appello non salvato'), findsNothing);
      expect(find.text('Apri'), findsOneWidget);
    });

    testWidgets('salvare registra l\'appello e chiude la schermata', (tester) async {
      await apriAppello(tester);
      await tester.tap(find.text('Assente'));
      await tester.pump();

      await tester.tap(find.text('SALVA APPELLO'));
      await tester.pumpAndSettle();

      expect(presenze.salvataggi, [
        {'Andrea': StatoPresenza.assente},
      ]);
      expect(find.text('Apri'), findsOneWidget);
    });
  });
}
