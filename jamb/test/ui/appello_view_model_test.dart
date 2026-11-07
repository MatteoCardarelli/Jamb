import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/appello/view_model/appello_view_model.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';
import 'package:jamb/ui/dettaglio_ragazzo/view_model/presenze_ragazzo_view_model.dart';
import '../../testing/fakes/fake_presenza_repository.dart';
import '../../testing/fakes/fake_scout_repository.dart';
import '../../testing/models/presenza_di_test.dart';
import '../../testing/models/scout_di_test.dart';

final _evento = Evento(
  id: 'riunione',
  titolo: 'Riunione',
  dataInizio: DateTime(2026, 11, 7, 15),
  dataFine: DateTime(2026, 11, 7, 17),
  luogo: 'Sede',
  categorie: const ['Altro'],
  colorePrincipale: Colors.blue,
);

Future<void> _attendi() => Future.delayed(Duration.zero);

void main() {
  late FakeScoutRepository scout;
  late FakePresenzaRepository presenze;

  setUp(() {
    scout = FakeScoutRepository([
      scoutDiTest('Sofia', 'Orsi'),
      scoutDiTest('Andrea', 'Aquile'),
      scoutDiTest('Luca', 'Aquile'),
      scoutDiTest('Marco', ''),
    ]);
    presenze = FakePresenzaRepository(appelli: {
      'riunione': {'Luca': StatoPresenza.assente},
    });
  });

  group('AppelloViewModel', () {
    test('divide i ragazzi per squadriglia, chi non ne ha in fondo', () async {
      final vm = AppelloViewModel(_evento, scout, presenze);
      await _attendi();

      expect(vm.perSquadriglia.keys, ['Aquile', 'Orsi', AppelloViewModel.senzaSquadriglia]);
      expect(vm.perSquadriglia['Aquile']!.map((r) => r.nome), ['Andrea', 'Luca']);
    });

    test("riparte dall'appello già registrato, senza modifiche", () async {
      final vm = AppelloViewModel(_evento, scout, presenze);
      await _attendi();

      expect(vm.statoDi('Luca'), StatoPresenza.assente);
      expect(vm.daSegnare, 3);
      expect(vm.modificato, isFalse);
    });

    // «Tutti presenti» è la scorciatoia d'inizio appello: non deve
    // cancellare un'assenza già segnata.
    test('«tutti presenti» non sovrascrive chi è già segnato', () async {
      final vm = AppelloViewModel(_evento, scout, presenze);
      await _attendi();

      vm.tuttiPresenti();

      expect(vm.statoDi('Luca'), StatoPresenza.assente);
      expect(vm.conta(StatoPresenza.presente), 3);
      expect(vm.daSegnare, 0);
    });

    test('salva solo le modifiche, in una sola scrittura', () async {
      final vm = AppelloViewModel(_evento, scout, presenze);
      await _attendi();

      vm
        ..imposta('Sofia', StatoPresenza.presente)
        ..imposta('Andrea', StatoPresenza.giustificato)
        ..imposta('Luca', StatoPresenza.assente); // invariato
      await vm.salva();

      expect(presenze.salvataggi, [
        {'Sofia': StatoPresenza.presente, 'Andrea': StatoPresenza.giustificato},
      ]);
      expect(vm.modificato, isFalse);
    });

    test("tornare allo stato salvato annulla la modifica", () async {
      final vm = AppelloViewModel(_evento, scout, presenze);
      await _attendi();

      vm.imposta('Luca', StatoPresenza.presente);
      expect(vm.modificato, isTrue);
      vm.imposta('Luca', StatoPresenza.assente);
      expect(vm.modificato, isFalse);
    });

    test('se il salvataggio fallisce le modifiche restano da salvare', () async {
      presenze.erroreScrittura =
          const JambException(TipoErrore.rete, 'Connessione assente.');
      final vm = AppelloViewModel(_evento, scout, presenze);
      await _attendi();

      vm.imposta('Sofia', StatoPresenza.presente);

      await expectLater(vm.salva(), throwsA(isA<JambException>()));
      expect(vm.modificato, isTrue);
    });

    test('un errore di lettura porta allo stato errore', () async {
      presenze.erroreLettura =
          const JambException(TipoErrore.rete, 'Connessione assente.');
      final vm = AppelloViewModel(_evento, scout, presenze);
      await _attendi();

      expect(vm.stato, StatoCaricamento.errore);
    });
  });

  group('PresenzeRagazzoViewModel', () {
    final adesso = DateTime(2026, 10, 31);

    test('segnala le assenze ripetute dalla soglia in su', () async {
      final repo = FakePresenzaRepository(storici: {
        'Luca': [
          presenzaDiTest(1, StatoPresenza.presente),
          presenzaDiTest(8, StatoPresenza.assente),
          presenzaDiTest(15, StatoPresenza.assente),
          presenzaDiTest(22, StatoPresenza.assente),
        ],
      });
      final vm = PresenzeRagazzoViewModel('Luca', repo, adesso: adesso);
      await _attendi();

      expect(vm.serieAssenze, sogliaAssenzeRipetute);
      expect(vm.assenzeRipetute, isTrue);
      expect(vm.riepilogo, 'Presente a 1 attività su 4');
    });

    test("si aggiorna quando viene salvato un appello", () async {
      final repo = FakePresenzaRepository(storici: {'Luca': []});
      final vm = PresenzeRagazzoViewModel('Luca', repo, adesso: adesso);
      await _attendi();
      expect(vm.riepilogo, isEmpty);

      repo.storici['Luca']!.add(presenzaDiTest(20, StatoPresenza.presente));
      await repo.salvaAppello('evento-20', {'Luca': StatoPresenza.presente});
      await _attendi();

      expect(vm.riepilogo, 'Presente a 1 attività su 1');
      expect(vm.assenzeRipetute, isFalse);
    });
  });
}
