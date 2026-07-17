import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';
import '../../testing/fakes/fake_transazione_repository.dart';
import '../../testing/models/transazione_di_test.dart';

void main() {
  group('ContabilitaViewModel', () {
    test('saldoAttuale = entrate - uscite', () async {
      final vm = ContabilitaViewModel(FakeTransazioneRepository([
        transazioneDiTest('a', 100, false, Categoria.quote),
        transazioneDiTest('b', 30, true, Categoria.materiale),
      ]));
      await Future.delayed(Duration.zero); // attende il caricamento iniziale
      expect(vm.saldoAttuale, 70);
    });

    test('ripartizioneSpese calcola le quote per categoria', () async {
      final vm = ContabilitaViewModel(FakeTransazioneRepository([
        transazioneDiTest('a', 30, true, Categoria.materiale),
        transazioneDiTest('b', 20, true, Categoria.trasporto),
      ]));
      await Future.delayed(Duration.zero);
      expect(vm.ripartizioneSpese[Categoria.materiale], closeTo(0.6, 0.001));
      expect(vm.ripartizioneSpese[Categoria.trasporto], closeTo(0.4, 0.001));
    });
  });
}