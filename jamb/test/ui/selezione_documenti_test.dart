import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/explorer/view_model/explorer_view_model.dart';
import 'package:jamb/ui/explorer/widgets/griglia_documenti.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_documento_repository.dart';

Documento _doc(String id, {String? padre, bool cartella = false}) => Documento(
      id: id,
      nome: id,
      tipo: cartella ? TipoDocumento.cartella : TipoDocumento.pdf,
      parentId: padre,
      ultimaModifica: DateTime(2026, 11, 1),
      percorsoFile: cartella ? null : 'g/u/$id',
    );

void main() {
  late FakeDocumentoRepository repo;
  const archivio = ArchivioDocumenti.driveBranca;

  setUp(() {
    repo = FakeDocumentoRepository(archivi: {
      archivio: [
        _doc('Uscite', cartella: true),
        _doc('Campi', cartella: true),
        _doc('Estate', padre: 'Uscite', cartella: true),
        _doc('a.pdf'),
        _doc('b.pdf'),
        _doc('dentro.pdf', padre: 'Uscite'),
      ],
    });
  });

  Future<ExplorerViewModel> radice() async {
    final vm = ExplorerViewModel(repository: repo, archivio: archivio, titolo: 'Drive');
    await pumpEventQueue();
    return vm;
  }

  Documento di(ExplorerViewModel vm, String id) =>
      vm.contenutoFiltrato.firstWhere((d) => d.id == id);

  String? padreDi(String id) => repo.archivi[archivio]!.firstWhere((d) => d.id == id).parentId;

  group('alberoCartelle', () {
    test('ogni cartella è seguita dalle sue sottocartelle, in ordine', () {
      final voci = alberoCartelle([
        _doc('Uscite', cartella: true),
        _doc('Estate', padre: 'Uscite', cartella: true),
        _doc('Campi', cartella: true),
      ]);
      expect(voci.map((v) => (v.nome, v.livello)), [('Campi', 1), ('Uscite', 1), ('Estate', 2)]);
    });

    // Spostare una cartella dentro una sua sottocartella la farebbe sparire.
    test('una cartella esclusa porta con sé il suo contenuto', () {
      final voci = alberoCartelle([
        _doc('Uscite', cartella: true),
        _doc('Estate', padre: 'Uscite', cartella: true),
        _doc('Agosto', padre: 'Estate', cartella: true),
      ], escluse: {'Uscite'});
      expect(voci, isEmpty);
    });

    test('un ciclo nei dati non blocca il calcolo', () {
      final voci = alberoCartelle([
        _doc('Radice', cartella: true),
        _doc('A', padre: 'B', cartella: true),
        _doc('B', padre: 'A', cartella: true),
      ]);
      expect(voci.map((v) => v.nome), ['Radice']);
    });
  });

  group('selezione', () {
    test('selezionare e deselezionare chiude la modalità', () async {
      final vm = await radice();
      vm.alternaSelezione(di(vm, 'a.pdf'));
      expect(vm.inSelezione, isTrue);
      vm.alternaSelezione(di(vm, 'a.pdf'));
      expect(vm.inSelezione, isFalse);
    });

    test('il tocco prolungato non toglie un elemento già scelto', () async {
      final vm = await radice();
      vm.includiNellaSelezione(di(vm, 'a.pdf'));
      vm.includiNellaSelezione(di(vm, 'a.pdf'));
      expect(vm.numeroSelezionati, 1);
    });

    test('«seleziona tutto» rispetta la ricerca', () async {
      final vm = await radice();
      vm.searchController.text = 'a.pdf';
      vm.selezionaTutti();
      expect(vm.selezionati.map((d) => d.id), ['a.pdf']);
    });

    test('ciò che sparisce dopo una ricarica esce dalla selezione', () async {
      final vm = await radice();
      vm.includiNellaSelezione(di(vm, 'a.pdf'));
      vm.includiNellaSelezione(di(vm, 'b.pdf'));
      await repo.elimina(archivio, di(vm, 'a.pdf'));
      await pumpEventQueue();
      expect(vm.selezionati.map((d) => d.id), ['b.pdf']);
    });

    test('eliminare più elementi toglie anche il contenuto delle cartelle', () async {
      final vm = await radice();
      vm.includiNellaSelezione(di(vm, 'Uscite'));
      vm.includiNellaSelezione(di(vm, 'a.pdf'));
      await vm.eliminaSelezione();
      await pumpEventQueue();
      expect(repo.archivi[archivio]!.map((d) => d.id), ['Campi', 'b.pdf']);
      expect(vm.inSelezione, isFalse);
    });
  });

  group('spostamento', () {
    test('sposta tutta la selezione e la chiude', () async {
      final vm = await radice();
      vm.includiNellaSelezione(di(vm, 'a.pdf'));
      vm.includiNellaSelezione(di(vm, 'b.pdf'));

      expect(await vm.spostaSelezione('Uscite'), 2);
      await pumpEventQueue();

      expect(padreDi('a.pdf'), 'Uscite');
      expect(padreDi('b.pdf'), 'Uscite');
      expect(vm.inSelezione, isFalse);
      expect(vm.contenutoFiltrato.map((d) => d.id), ['Campi', 'Uscite']);
    });

    test('dalla sottocartella si torna alla radice', () async {
      final vm = ExplorerViewModel(
        repository: repo,
        archivio: archivio,
        titolo: 'Uscite',
        parentId: 'Uscite',
        percorsoPrecedente: const ['Drive'],
        idPercorsoPrecedente: const [null],
      );
      await pumpEventQueue();
      expect(vm.idPercorso, [null, 'Uscite']);

      vm.includiNellaSelezione(di(vm, 'dentro.pdf'));
      await vm.spostaSelezione(vm.idPercorso.first);

      expect(padreDi('dentro.pdf'), isNull);
    });

    test('una cartella non può finire dentro sé stessa', () async {
      final vm = await radice();
      vm.includiNellaSelezione(di(vm, 'Uscite'));
      await expectLater(vm.spostaSelezione('Uscite'), throwsA(isA<JambException>()));
      expect(padreDi('Uscite'), isNull);
    });

    test('una cartella selezionata non riceve, un file nemmeno', () async {
      final vm = await radice();
      vm.includiNellaSelezione(di(vm, 'Uscite'));
      expect(vm.puoRicevere(di(vm, 'Uscite')), isFalse);
      expect(vm.puoRicevere(di(vm, 'a.pdf')), isFalse);
      expect(vm.puoRicevere(di(vm, 'Campi')), isTrue);
    });

    test('se lo spostamento fallisce la selezione resta', () async {
      final vm = await radice();
      vm.includiNellaSelezione(di(vm, 'a.pdf'));
      repo.erroreScrittura = const JambException(TipoErrore.permessoNegato, 'No');
      await expectLater(vm.spostaSelezione('Uscite'), throwsA(isA<JambException>()));
      expect(vm.numeroSelezionati, 1);
    });

    test('le destinazioni escludono la cartella scelta e il suo contenuto', () async {
      final vm = await radice();
      vm.includiNellaSelezione(di(vm, 'Uscite'));
      final voci = await vm.destinazioni();
      expect(voci.map((v) => v.id), ['Campi']);
    });

    test('da una sottocartella la radice è una destinazione, quella aperta no', () async {
      final vm = ExplorerViewModel(
        repository: repo,
        archivio: archivio,
        titolo: 'Uscite',
        parentId: 'Uscite',
      );
      await pumpEventQueue();
      vm.includiNellaSelezione(di(vm, 'dentro.pdf'));
      final voci = await vm.destinazioni();
      expect(voci.first.id, isNull);
      expect(voci.map((v) => v.id), isNot(contains('Uscite')));
      expect(voci.map((v) => v.id), contains('Estate'));
    });
  });

  group('GrigliaDocumenti', () {
    Future<void> monta(
      WidgetTester tester,
      ExplorerViewModel vm, {
      bool puoModificare = true,
      ValueChanged<Documento>? onApri,
      ValueChanged<Documento>? onRilascia,
    }) async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          home: Scaffold(
            body: GrigliaDocumenti(
              puoModificare: puoModificare,
              onApri: onApri ?? (_) {},
              onRilascia: onRilascia ?? (_) {},
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets('fuori dalla selezione un tocco apre', (tester) async {
      final vm = ExplorerViewModel(repository: repo, archivio: archivio, titolo: 'Drive');
      await tester.pump();
      Documento? aperto;
      await monta(tester, vm, onApri: (d) => aperto = d);
      await tester.tap(find.text('a.pdf'));
      expect(aperto?.id, 'a.pdf');
    });

    testWidgets('il tocco prolungato seleziona, e allora un tocco non apre', (tester) async {
      final vm = ExplorerViewModel(repository: repo, archivio: archivio, titolo: 'Drive');
      await tester.pump();
      Documento? aperto;
      await monta(tester, vm, onApri: (d) => aperto = d);

      await tester.longPress(find.text('a.pdf'));
      await tester.pumpAndSettle();
      expect(vm.selezionati.map((d) => d.id), ['a.pdf']);

      await tester.tap(find.text('b.pdf'));
      await tester.pump();
      expect(aperto, isNull);
      expect(vm.numeroSelezionati, 2);
    });

    testWidgets('trascinare un file su una cartella la indica come destinazione', (tester) async {
      final vm = ExplorerViewModel(repository: repo, archivio: archivio, titolo: 'Drive');
      await tester.pump();
      Documento? destinazione;
      await monta(tester, vm, onRilascia: (d) => destinazione = d);

      final gesto = await tester.startGesture(tester.getCenter(find.text('a.pdf')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(vm.selezionati.map((d) => d.id), ['a.pdf']);

      await gesto.moveTo(tester.getCenter(find.text('Campi')));
      await tester.pump();
      await gesto.up();
      await tester.pumpAndSettle();

      expect(destinazione?.id, 'Campi');
    });

    testWidgets('rilasciare sulla cartella stessa non la sposta', (tester) async {
      final vm = ExplorerViewModel(repository: repo, archivio: archivio, titolo: 'Drive');
      await tester.pump();
      Documento? destinazione;
      await monta(tester, vm, onRilascia: (d) => destinazione = d);

      final gesto = await tester.startGesture(tester.getCenter(find.text('Campi')));
      await tester.pump(const Duration(milliseconds: 600));
      await gesto.moveBy(const Offset(3, 3));
      await tester.pump();
      await gesto.up();
      await tester.pumpAndSettle();

      expect(destinazione, isNull);
      expect(vm.inSelezione, isTrue);
    });

    // Chi legge soltanto non deve poter selezionare né trascinare.
    testWidgets('senza permessi il tocco prolungato non fa nulla', (tester) async {
      final vm = ExplorerViewModel(repository: repo, archivio: archivio, titolo: 'Drive');
      await tester.pump();
      await monta(tester, vm, puoModificare: false);
      await tester.longPress(find.text('a.pdf'));
      await tester.pumpAndSettle();
      expect(vm.inSelezione, isFalse);
    });
  });

  group('BarraSelezione', () {
    Future<void> monta(WidgetTester tester, int numero) => tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: BarraSelezione(
              numero: numero,
              onChiudi: () {},
              onTutti: () {},
              onSposta: () {},
              onRinomina: () {},
              onElimina: () {},
            ),
          ),
        ));

    testWidgets('con un elemento si può rinominare', (tester) async {
      await monta(tester, 1);
      expect(find.text('1 selezionato'), findsOneWidget);
      expect(find.byTooltip('Rinomina'), findsOneWidget);
    });

    testWidgets('con più elementi no', (tester) async {
      await monta(tester, 3);
      expect(find.text('3 selezionati'), findsOneWidget);
      expect(find.byTooltip('Rinomina'), findsNothing);
      expect(find.byTooltip('Sposta in…'), findsOneWidget);
    });
  });
}
