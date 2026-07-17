import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/ui/ragazzi/view_model/ragazzi_view_model.dart';
import '../../testing/fakes/fake_scout_repository.dart';
import '../../testing/models/scout_di_test.dart';

void main() {
  group('RagazziViewModel', () {
    RagazziViewModel costruisci() => RagazziViewModel(FakeScoutRepository([
          scoutDiTest('Andrea Conti', 'Aquile', allergie: 'noci'),
          scoutDiTest('Luca Ferrari', 'Aquile'),
          scoutDiTest('Sofia Marino', 'Orsi', allergie: 'lattosio'),
        ]));

    test('senza filtri restituisce tutti i ragazzi', () async {
      final vm = costruisci();
      await Future.delayed(Duration.zero);
      expect(vm.ragazziFiltrati.length, 3);
    });

    test('filtro per squadriglia', () async {
      final vm = costruisci();
      await Future.delayed(Duration.zero);
      vm.setSquadrigliaFiltro('Aquile');
      expect(vm.ragazziFiltrati.length, 2);
    });

    test('filtro alert mostra solo chi ha allergie', () async {
      final vm = costruisci();
      await Future.delayed(Duration.zero);
      vm.setAlertFiltro(true);
      expect(vm.ragazziFiltrati.length, 2);
    });
  });
}