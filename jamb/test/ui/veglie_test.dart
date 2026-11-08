import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/repositories/supabase_veglia_repository.dart';
import 'package:jamb/domain/entities/veglia.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/veglie/view_model/veglie_view_model.dart';
import 'package:jamb/ui/veglie/widgets/veglie_screen.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_veglia_repository.dart';

const _rs = Veglia(id: '1', titolo: 'Avvento', branca: BrancaVeglia.rs);
const _eg = Veglia(id: '2', titolo: 'Campo', branca: BrancaVeglia.eg);

void main() {
  group('valori dal database', () {
    test('una branca sconosciuta degrada alla Co.Ca.', () {
      expect(BrancaVeglia.daDb('NUOVA'), BrancaVeglia.coca);
    });

    test('un tipo di momento sconosciuto degrada a riflessione', () {
      expect(TipoMomento.daNome('danza'), TipoMomento.riflessione);
    });

    test('una struttura malformata non blocca la lettura', () {
      expect(SupabaseVegliaRepository.momentiDaJson('rotto'), isEmpty);
      expect(SupabaseVegliaRepository.momentiDaJson(null), isEmpty);
      expect(
        SupabaseVegliaRepository.momentiDaJson([
          {'tipo': 'canto', 'testo': 'Alleluia'},
          'non una mappa',
        ]).single.tipo,
        TipoMomento.canto,
      );
    });
  });

  group('VeglieViewModel', () {
    test('il filtro mostra solo la branca scelta', () async {
      final vm = VeglieViewModel(FakeVegliaRepository([_rs, _eg]));
      await pumpEventQueue();
      expect(vm.veglie, hasLength(2));
      vm.setFiltro(BrancaVeglia.eg);
      expect(vm.veglie, [_eg]);
      vm.setFiltro(null);
      expect(vm.veglie, hasLength(2));
    });

    test('un errore di lettura diventa uno stato di errore', () async {
      final repo = FakeVegliaRepository()
        ..erroreLettura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = VeglieViewModel(repo);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  group('FormVegliaViewModel', () {
    FormVegliaViewModel conTre() => FormVegliaViewModel(FakeVegliaRepository())
      ..aggiungiMomento(TipoMomento.canto, 'A')
      ..aggiungiMomento(TipoMomento.lettura, 'B')
      ..aggiungiMomento(TipoMomento.silenzio, 'C');

    test('serve un titolo e almeno un momento', () {
      final vm = FormVegliaViewModel(FakeVegliaRepository());
      expect(vm.isValid, isFalse);
      vm.setTitolo('Avvento');
      expect(vm.isValid, isFalse);
      vm.aggiungiMomento(TipoMomento.canto, 'Alleluia');
      expect(vm.isValid, isTrue);
    });

    test('spostare un momento cambia l\'ordine', () {
      final vm = conTre()..spostaMomento(2, -1);
      expect(vm.momenti.map((m) => m.testo), ['A', 'C', 'B']);
    });

    test('spostare oltre i limiti non cambia nulla', () {
      final vm = conTre()
        ..spostaMomento(0, -1)
        ..spostaMomento(2, 1);
      expect(vm.momenti.map((m) => m.testo), ['A', 'B', 'C']);
    });

    test('una veglia nuova si crea, una esistente si aggiorna', () async {
      final repo = FakeVegliaRepository([_rs]);
      await (FormVegliaViewModel(repo)
            ..setTitolo('Nuova')
            ..aggiungiMomento(TipoMomento.canto, 'A'))
          .salva();
      expect(repo.veglie, hasLength(2));

      await (FormVegliaViewModel(repo, esistente: _rs)..setTitolo('Rinominata')).salva();
      expect(repo.veglie, hasLength(2));
      expect(repo.veglie.first.titolo, 'Rinominata');
    });

    test('un errore di salvataggio arriva alla View', () async {
      final repo = FakeVegliaRepository()
        ..erroreScrittura = const JambException(TipoErrore.permessoNegato, 'Non consentito');
      final vm = FormVegliaViewModel(repo)..setTitolo('X');
      await expectLater(vm.salva(), throwsA(isA<JambException>()));
    });
  });

  group('VeglieView', () {
    Future<void> monta(WidgetTester tester, {required bool puoModificare}) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => VeglieViewModel(FakeVegliaRepository([_rs])),
        child: MaterialApp(home: VeglieView(puoModificare: puoModificare)),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('un capo legge ma non crea né modifica', (tester) async {
      await monta(tester, puoModificare: false);
      expect(find.text('Nuova veglia'), findsNothing);
      await tester.tap(find.text('Avvento'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Elimina'), findsNothing);
    });

    testWidgets('l\'Assistente può creare e modificare', (tester) async {
      await monta(tester, puoModificare: true);
      expect(find.text('Nuova veglia'), findsOneWidget);
      await tester.tap(find.text('Avvento'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Elimina'), findsOneWidget);
    });
  });
}
