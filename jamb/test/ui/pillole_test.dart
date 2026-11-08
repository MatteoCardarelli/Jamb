import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/pillola.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/pillole/view_model/pillole_view_model.dart';
import 'package:jamb/ui/pillole/widgets/pillole_screen.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_pillola_repository.dart';

const _a = Pillola(id: 'a', testo: 'Prima', comune: true);
const _b = Pillola(id: 'b', testo: 'Seconda');
const _c = Pillola(id: 'c', testo: 'Terza');

void main() {
  group('pillolaDelGiorno', () {
    test('resta la stessa per tutta la giornata', () {
      final mattina = pillolaDelGiorno([_a, _b, _c], DateTime(2026, 11, 8, 0, 1));
      final sera = pillolaDelGiorno([_a, _b, _c], DateTime(2026, 11, 8, 23, 59));
      expect(mattina, same(sera));
    });

    test('non dipende dall\'ordine in cui arrivano', () {
      final data = DateTime(2026, 11, 8);
      expect(pillolaDelGiorno([_a, _b, _c], data), same(pillolaDelGiorno([_c, _a, _b], data)));
    });

    test('in giorni consecutivi le mostra tutte prima di ripeterle', () {
      final viste = {
        for (var g = 1; g <= 3; g++) pillolaDelGiorno([_a, _b, _c], DateTime(2026, 11, g))!.id,
      };
      expect(viste, {'a', 'b', 'c'});
    });

    // Il 25 ottobre 2026 dura 25 ore in Italia: non deve saltare una pillola.
    test('il cambio dell\'ora legale non salta un giorno', () {
      final viste = {
        for (var g = 24; g <= 26; g++) pillolaDelGiorno([_a, _b, _c], DateTime(2026, 10, g))!.id,
      };
      expect(viste, hasLength(3));
    });

    test('senza pillole non ce n\'è una del giorno', () {
      expect(pillolaDelGiorno(const [], DateTime(2026, 11, 8)), isNull);
    });
  });

  group('errorePillola', () {
    test('rifiuta testi vuoti e oltre il limite del DB', () {
      expect(errorePillola('   '), isNotNull);
      expect(errorePillola('a' * 501), isNotNull);
      expect(errorePillola('a' * 500), isNull);
    });
  });

  group('PilloleViewModel', () {
    test('espone la pillola di oggi e si aggiorna dopo una scrittura', () async {
      final repo = FakePillolaRepository();
      final vm = PilloleViewModel(repo, oggi: () => DateTime(2026, 11, 8));
      await pumpEventQueue();
      expect(vm.delGiorno, isNull);

      await vm.crea('Nuova');
      await pumpEventQueue();

      expect(vm.delGiorno?.testo, 'Nuova');
    });

    // La pillola della Home resta del metodo anche con molti spunti.
    test('gli spunti non entrano nella pillola del giorno', () async {
      final vm = PilloleViewModel(FakePillolaRepository(null, [_b]), oggi: () => DateTime(2026, 11, 8));
      await pumpEventQueue();
      expect(vm.delGiorno, isNull);
      expect(vm.pilloleDi(TipoPillola.spiritualita), [_b]);
    });

    test('un errore di lettura diventa uno stato di errore', () async {
      final repo = FakePillolaRepository()
        ..erroreLettura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = PilloleViewModel(repo);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  group('PilloleView', () {
    Future<void> monta(WidgetTester tester, {required bool puoModificare}) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => PilloleViewModel(FakePillolaRepository([_a, _b])),
        child: MaterialApp(home: PilloleView(puoModificare: puoModificare)),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('chi può scrivere modifica le pillole del gruppo', (tester) async {
      await monta(tester, puoModificare: true);
      expect(find.text('Nuova pillola'), findsOneWidget);
      await tester.longPress(find.text('Seconda'));
      await tester.pumpAndSettle();
      expect(find.text('Modifica'), findsOneWidget);
    });

    // Le policy rifiutano di toccare le pillole con `group_id` nullo.
    testWidgets('una pillola comune non offre azioni', (tester) async {
      await monta(tester, puoModificare: true);
      await tester.longPress(find.text('Prima'));
      await tester.pumpAndSettle();
      expect(find.text('Modifica'), findsNothing);
    });

    testWidgets('gli spunti li modifica l\'Assistente, non chi scrive il metodo', (tester) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => PilloleViewModel(FakePillolaRepository([_a], [_b])),
        child: const MaterialApp(
          home: PilloleView(puoModificare: true, tipoIniziale: TipoPillola.spiritualita),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Seconda'), findsOneWidget);
      expect(find.text('Nuova pillola'), findsNothing);
      await tester.tap(find.text('Metodo'));
      await tester.pumpAndSettle();
      expect(find.text('Nuova pillola'), findsOneWidget);
    });

    testWidgets('l\'Assistente modifica gli spunti ma non il metodo', (tester) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => PilloleViewModel(FakePillolaRepository([_a], [_b])),
        child: const MaterialApp(
          home: PilloleView(
            puoModificare: false,
            puoModificareSpiritualita: true,
            tipoIniziale: TipoPillola.spiritualita,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Nuova pillola'), findsOneWidget);
      await tester.tap(find.text('Metodo'));
      await tester.pumpAndSettle();
      expect(find.text('Nuova pillola'), findsNothing);
    });

    testWidgets('l\'Aiuto Capo legge soltanto', (tester) async {
      await monta(tester, puoModificare: false);
      expect(find.text('Nuova pillola'), findsNothing);
      await tester.longPress(find.text('Seconda'));
      await tester.pumpAndSettle();
      expect(find.text('Modifica'), findsNothing);
    });
  });
}
