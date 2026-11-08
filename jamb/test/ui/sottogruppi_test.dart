import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/sottogruppi/view_model/sottogruppi_view_model.dart';
import 'package:jamb/ui/sottogruppi/widgets/sottogruppi_screen.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_sottogruppo_repository.dart';

const _anna = MembroUnita(id: 'a', nome: 'Anna', ruolo: 'RAGAZZO', squadriglia: 'Aquile');
const _bruno = MembroUnita(id: 'b', nome: 'Bruno', ruolo: 'CAPO_UNITA');

FakeSottogruppoRepository _repo() => FakeSottogruppoRepository(
      squadriglie: [
        const Squadriglia(id: '1', nome: 'Aquile'),
        const Squadriglia(id: '2', nome: 'Orsi'),
      ],
      membri: [_anna, _bruno],
    );

void main() {
  group('SottogruppiViewModel', () {
    Future<SottogruppiViewModel> crea(FakeSottogruppoRepository repo) async {
      final vm = SottogruppiViewModel(repo, SottogruppiBranca.di('EG'));
      await pumpEventQueue();
      return vm;
    }

    test('rinominare una squadriglia non perde i suoi ragazzi', () async {
      final vm = await crea(_repo());
      await vm.rinomina(vm.attive.first, 'Falchi');
      await pumpEventQueue();
      final falchi = vm.attive.singleWhere((s) => s.nome == 'Falchi');
      expect(vm.membriDella(falchi).map((m) => m.id), ['a']);
    });

    test('non si disattiva una squadriglia con ragazzi', () async {
      final repo = _repo();
      final vm = await crea(repo);
      await expectLater(vm.disattiva(vm.attive.first), throwsA(isA<JambException>()));
      expect(repo.squadriglie.first.attiva, isTrue);
    });

    test('una squadriglia vuota si disattiva e passa tra le disattivate', () async {
      final vm = await crea(_repo());
      await vm.disattiva(vm.attive.last);
      await pumpEventQueue();
      expect(vm.disattivate.map((s) => s.nome), ['Orsi']);
      expect(vm.attive.map((s) => s.nome), ['Aquile']);
    });

    test('chi ha lasciato l\'unità sparisce dal sottogruppo', () async {
      final repo = _repo()
        ..sottogruppi.add(const Sottogruppo(
          tipo: TipoSottogruppo.altaSquadriglia,
          membri: {'a', 'uscito'},
        ));
      final vm = await crea(repo);
      expect(vm.membriSottogruppo(TipoSottogruppo.altaSquadriglia).map((m) => m.id), ['a']);
    });

    test('tra i candidati di un sottogruppo non ci sono i capi', () async {
      final vm = await crea(_repo());
      expect(vm.ragazzi.map((m) => m.id), ['a']);
    });

    test('il nome di una nuova squadriglia dev\'essere libero', () async {
      final vm = await crea(_repo());
      expect(vm.erroreNome('aquile'), isNotNull);
      expect(vm.erroreNome('Volpi'), isNull);
    });
  });

  group('SottogruppiView', () {
    Future<void> monta(WidgetTester tester, {required bool puoModificare}) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => SottogruppiViewModel(_repo(), SottogruppiBranca.di('EG')),
        child: MaterialApp(home: SottogruppiView(puoModificare: puoModificare)),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('il Capo Unità può aggiungere e scegliere i componenti', (tester) async {
      await monta(tester, puoModificare: true);
      expect(find.text('Nuova squadriglia'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Scegli i componenti'), 200);
      expect(find.text('Scegli i componenti'), findsOneWidget);
    });

    // La policy di `squads` rifiuterebbe la scrittura: l'azione non si mostra.
    testWidgets('l\'Aiuto Capo consulta soltanto', (tester) async {
      await monta(tester, puoModificare: false);
      expect(find.text('Aquile'), findsOneWidget);
      expect(find.text('Nuova squadriglia'), findsNothing);
      expect(find.text('Scegli i componenti'), findsNothing);
      await tester.tap(find.text('Aquile'));
      await tester.pumpAndSettle();
      expect(find.text('Rinomina'), findsNothing);
    });
  });
}
