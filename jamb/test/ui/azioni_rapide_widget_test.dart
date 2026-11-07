import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/domain/repositories/evento_repository.dart';
import 'package:jamb/domain/repositories/presenza_repository.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/home/widgets/azioni_rapide_widget.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_evento_repository.dart';
import '../../testing/fakes/fake_presenza_repository.dart';
import '../../testing/fakes/fake_scout_repository.dart';
import '../../testing/models/evento_di_test.dart';
import '../../testing/models/scout_di_test.dart';

/// Azioni rapide con i repository finti che servono all'appello.
Widget _home(List<Evento> eventi) => MultiProvider(
      providers: [
        ChangeNotifierProvider<IEventoRepository>(
          create: (_) => FakeEventoRepository(eventi: eventi),
        ),
        ChangeNotifierProvider<IScoutRepository>(
          create: (_) => FakeScoutRepository([scoutDiTest('Andrea', 'Aquile')]),
        ),
        ChangeNotifierProvider<IPresenzaRepository>(
          create: (_) => FakePresenzaRepository(),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: AzioniRapideWidget())),
      ),
    );

void main() {
  group('Appello dalla Home', () {
    testWidgets("apre l'appello dell'evento in corso", (tester) async {
      final adesso = DateTime.now();
      await tester.pumpWidget(_home([
        eventoDiTest(
          'Riunione in corso',
          adesso.subtract(const Duration(minutes: 10)),
          fine: adesso.add(const Duration(hours: 1)),
        ),
      ]));

      await tester.tap(find.text('Appello'));
      await tester.pumpAndSettle();

      expect(find.text('Riunione in corso'), findsOneWidget);
      expect(find.text('Andrea'), findsOneWidget);
    });

    // Senza un evento adatto il tocco non deve sembrare ignorato.
    testWidgets('senza eventi in corso o recenti spiega dove trovarlo', (tester) async {
      await tester.pumpWidget(_home(const []));

      await tester.tap(find.text('Appello'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nessun evento in corso o recente'), findsOneWidget);
    });
  });
}
