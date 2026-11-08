import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/permessi.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/domain/entities/peg.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/peg/view_model/peg_view_model.dart';
import 'package:jamb/ui/peg/widgets/peg_screen.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_peg_repository.dart';

const _a = PegObiettivo(id: 'a', titolo: 'Essenzialità');
const _b = PegObiettivo(id: 'b', titolo: 'Servizio');

GradoCollegato _g(String id, int grado) => GradoCollegato(pegObiettivoId: id, grado: grado);

void main() {
  group('calcolaAvanzamentoPeg', () {
    test('media dei gradi collegati, per obiettivo', () {
      final av = calcolaAvanzamentoPeg([_a, _b], [_g('a', 2), _g('a', 5), _g('b', 3)]);
      expect(av[0].media, 3.5);
      expect(av[1].media, 3);
    });

    test('un obiettivo senza collegati non ha media ed è critico', () {
      final av = calcolaAvanzamentoPeg([_a], const []).single;
      expect(av.media, isNull);
      expect(av.frazione, isNull);
      expect(av.critico, isTrue);
    });

    test('la soglia critica è esclusa: 2,5 non è critico, sotto sì', () {
      expect(AvanzamentoPeg(obiettivo: _a, gradi: const [2, 3]).critico, isFalse);
      expect(AvanzamentoPeg(obiettivo: _a, gradi: const [2, 2]).critico, isTrue);
    });

    test('il grado 1 è zero avanzamento, il 5 è completo', () {
      expect(AvanzamentoPeg(obiettivo: _a, gradi: const [1]).frazione, 0);
      expect(AvanzamentoPeg(obiettivo: _a, gradi: const [5]).frazione, 1);
    });

    test('i gradi di obiettivi non più esistenti si ignorano', () {
      expect(calcolaAvanzamentoPeg([_a], [_g('sparito', 5)]).single.gradi, isEmpty);
    });
  });

  group('Obiettivo.copyWith e il collegamento al PEG', () {
    const base = Obiettivo(
      id: '1',
      dominio: 'd',
      descrizione: 'x',
      grado: 3,
      colore: Colors.teal,
      icona: Icons.star,
      pegObiettivoId: 'a',
    );

    test('senza indicarlo il collegamento resta', () {
      expect(base.copyWith(grado: 4).pegObiettivoId, 'a');
    });

    test('si può togliere passando null', () {
      expect(base.copyWith(pegObiettivoId: null).pegObiettivoId, isNull);
    });
  });

  group('PegViewModel', () {
    test('conta i punti critici dai gradi', () async {
      final vm = PegViewModel(FakePegRepository(obiettivi: [_a, _b], gradi: [_g('a', 5)]));
      await pumpEventQueue();
      expect(vm.critici, 1);
    });

    test('cambiare la premessa non perde il titolo', () async {
      final repo = FakePegRepository(peg: const Peg(titolo: 'Titolo'));
      final vm = PegViewModel(repo);
      await pumpEventQueue();
      await vm.salvaPremessa('La premessa');
      await pumpEventQueue();
      expect(vm.peg.titolo, 'Titolo');
      expect(vm.peg.premessa, 'La premessa');
    });

    test('rinominare un obiettivo non perde la descrizione', () async {
      const conDescrizione = PegObiettivo(id: 'a', titolo: 'T', descrizione: 'D');
      final repo = FakePegRepository(obiettivi: [conDescrizione]);
      final vm = PegViewModel(repo);
      await pumpEventQueue();
      await vm.rinominaObiettivo(conDescrizione, 'Nuovo');
      await pumpEventQueue();
      expect(vm.avanzamenti.single.obiettivo.descrizione, 'D');
      expect(vm.avanzamenti.single.obiettivo.titolo, 'Nuovo');
    });

    test('un errore di lettura diventa uno stato di errore', () async {
      final repo = FakePegRepository()
        ..erroreLettura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = PegViewModel(repo);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  test('un titolo vuoto non è valido', () {
    expect(erroreTitoloPeg('  '), isNotNull);
    expect(erroreTitoloPeg('Servizio'), isNull);
  });

  group('Permessi.puoScriverePeg', () {
    test('solo il Capo Gruppo', () {
      expect(const Permessi(ruolo: 'CAPO_UNITA').puoScriverePeg, isFalse);
      expect(const Permessi(capoGruppo: true).puoScriverePeg, isTrue);
    });
  });

  group('PegView', () {
    Future<void> monta(WidgetTester tester, {required bool puoModificare, bool conAvanzamento = true}) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => PegViewModel(FakePegRepository(obiettivi: [_a])),
        child: MaterialApp(home: PegView(puoModificare: puoModificare, conAvanzamento: conAvanzamento)),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('il Capo Gruppo può aggiungere obiettivi', (tester) async {
      await monta(tester, puoModificare: true);
      await tester.scrollUntilVisible(find.text('Nuovo obiettivo'), 200);
      expect(find.text('Nuovo obiettivo'), findsOneWidget);
    });

    testWidgets('un capo consulta soltanto', (tester) async {
      await monta(tester, puoModificare: false);
      expect(find.text('Nuovo obiettivo'), findsNothing);
      await tester.tap(find.text('Essenzialità'));
      await tester.pumpAndSettle();
      expect(find.text('Rinomina'), findsNothing);
    });

    // Non legge i Programmi d'Unità: non deve vedere tutto come critico.
    testWidgets('senza avanzamento non segnala punti critici', (tester) async {
      await monta(tester, puoModificare: false, conAvanzamento: false);
      expect(find.textContaining('Punto critico'), findsNothing);
    });
  });
}
