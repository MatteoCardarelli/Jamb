import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/dettaglio_ragazzo/view_model/dettaglio_ragazzo_view_model.dart';
import '../../testing/fakes/fake_scout_repository.dart';
import '../../testing/models/scout_di_test.dart';

void main() {
  group('DettaglioRagazzoViewModel', () {
    // Se il salvataggio fallisce la scheda non deve mostrare dati mai salvati:
    // con le allergie, un dato falso a schermo è un rischio concreto.
    test('un salvataggio fallito non modifica lo scout e propaga l\'errore', () async {
      final scout = scoutDiTest('Andrea', 'Aquile');
      final vm = DettaglioRagazzoViewModel(
        scout: scout,
        repository: FakeScoutRepository(
          [scout],
          erroreScrittura: const JambException(
              TipoErrore.permessoNegato, 'Non hai i permessi.'),
        ),
      );

      await expectLater(
        vm.aggiornaDati(scout.copyWith(allergie: 'Arachidi')),
        throwsA(isA<JambException>()),
      );
      expect(vm.scout.allergie, isNull);
    });

    test('un salvataggio riuscito aggiorna lo scout', () async {
      final scout = scoutDiTest('Andrea', 'Aquile');
      final vm = DettaglioRagazzoViewModel(
        scout: scout,
        repository: FakeScoutRepository([scout]),
      );

      await vm.aggiornaDati(scout.copyWith(allergie: 'Arachidi'));
      expect(vm.scout.allergie, 'Arachidi');
    });
  });
}
