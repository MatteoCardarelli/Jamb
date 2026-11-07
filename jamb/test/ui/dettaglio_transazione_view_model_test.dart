import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/contabilita/view_model/dettaglio_transazione_view_model.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';
import '../../testing/fakes/fake_transazione_repository.dart';
import '../../testing/models/transazione_di_test.dart';

Future<void> _attendi() => Future.delayed(Duration.zero);

void main() {
  final spesa = transazioneDiTest('corda', 30, true, Categoria.materiale);

  group('DettaglioTransazioneViewModel', () {
    test('senza ricevuta non chiede nessun URL', () async {
      final repo = FakeTransazioneRepository([]);
      final vm = DettaglioTransazioneViewModel(spesa, repo);
      await _attendi();

      expect(vm.haRicevuta, isFalse);
      expect(repo.urlRichiesti, isEmpty);
    });

    test("con la ricevuta ne ottiene l'URL dal percorso archiviato", () async {
      final repo = FakeTransazioneRepository([]);
      final vm = DettaglioTransazioneViewModel(
        spesa.copyWith(percorsoRicevuta: 'g/u/abc.jpg'),
        repo,
      );
      await _attendi();

      expect(repo.urlRichiesti, ['g/u/abc.jpg']);
      expect(vm.urlRicevuta, 'https://archivio.test/ricevute/g/u/abc.jpg');
      expect(vm.ricevutaPdf, isFalse);
    });

    // Un PDF non si può mostrare come immagine: va aperto fuori dall'app.
    test('riconosce una ricevuta in PDF', () {
      final vm = DettaglioTransazioneViewModel(
        spesa.copyWith(percorsoRicevuta: 'g/u/abc.PDF'),
        FakeTransazioneRepository([]),
      );
      expect(vm.ricevutaPdf, isTrue);
    });

    test('se la ricevuta non si ottiene si può riprovare', () async {
      final repo = FakeTransazioneRepository(
        [],
        erroreLettura: const JambException(TipoErrore.rete, 'Connessione assente.'),
      );
      final vm = DettaglioTransazioneViewModel(
        spesa.copyWith(percorsoRicevuta: 'g/u/abc.jpg'),
        repo,
      );
      await _attendi();
      expect(vm.stato, StatoCaricamento.errore);

      repo.erroreLettura = null;
      await vm.caricaRicevuta();
      expect(vm.urlRicevuta, isNotNull);
    });
  });
}
