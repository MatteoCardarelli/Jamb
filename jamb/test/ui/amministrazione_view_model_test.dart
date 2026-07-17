import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/ui/amministrazione/view_model/amministrazione_view_model.dart';
import '../../testing/fakes/fake_scout_repository.dart';
import '../../testing/models/scout_di_test.dart';

void main() {
  group('AmministrazioneViewModel', () {
    AmministrazioneViewModel costruisci() =>
        AmministrazioneViewModel(FakeScoutRepository([
          scoutDiTest('Andrea', 'Aquile'), // tutti i documenti validi
          scoutDiTest('Luca', 'Aquile', med: DocumentoStatus.scaduto),
          scoutDiTest('Sofia', 'Orsi', priv: DocumentoStatus.inScadenza),
        ]));

    test('ragazziTuttoOk conta chi ha tutti i documenti a posto', () async {
      final vm = costruisci();
      await Future.delayed(Duration.zero);
      expect(vm.ragazziTuttoOk, 2); // Andrea e Sofia (in scadenza conta come ok)
    });

    test('alertMessage segnala le schede mediche scadute', () async {
      final vm = costruisci();
      await Future.delayed(Duration.zero);
      expect(vm.alertMessage.contains('1 schede mediche scadute'), true);
    });
  });
}