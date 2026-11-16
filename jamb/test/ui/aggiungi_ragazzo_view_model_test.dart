import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/ragazzi/view_model/aggiungi_ragazzo_view_model.dart';
import '../../testing/fakes/fake_scout_repository.dart';
import '../../testing/models/scout_di_test.dart';

void main() {
  group('AggiungiRagazzoViewModel', () {
    late FakeScoutRepository repo;
    final oggi = DateTime(2026, 11, 16);

    AggiungiRagazzoViewModel costruisci() =>
        AggiungiRagazzoViewModel(repo, oggi: () => oggi);

    setUp(() {
      repo = FakeScoutRepository([
        scoutDiTest('Andrea Conti', 'Aquile'),
        scoutDiTest('Sofia Marino', 'Volpi'),
      ]);
    });

    test('senza nome o cognome non è valido e non scrive nulla', () async {
      final vm = costruisci();
      vm.setNome('Giulia');
      vm.setCognome('   ');
      expect(vm.isValid, isFalse);

      await vm.salva();
      expect(repo.aggiunti, isEmpty);
    });

    test(
      'salva nome e cognome senza spazi, senza squadriglia se non scelta',
      () async {
        final vm = costruisci();
        vm.setNome('  Giulia ');
        vm.setCognome(' Rossi  ');

        await vm.salva();

        final aggiunto = repo.aggiunti.single;
        expect(aggiunto.nome, 'Giulia');
        expect(aggiunto.cognome, 'Rossi');
        expect(aggiunto.squadriglia, isNull);
        expect(aggiunto.ruolo, 'RAGAZZO');
        expect(vm.aggiunti, 1);
      },
    );

    test(
      '«aggiungi un altro» svuota i campi ma tiene la squadriglia',
      () async {
        final vm = costruisci();
        await Future.delayed(Duration.zero);
        vm.setNome('Giulia');
        vm.setCognome('Rossi');
        vm.setDataNascita(DateTime(2013, 4, 2));
        vm.setSquadriglia('Volpi');
        vm.setRuolo('VICE_CAPO_SQ');
        await vm.salva();

        vm.preparaProssimo();

        expect(vm.nome, isEmpty);
        expect(vm.cognome, isEmpty);
        expect(vm.dataNascita, isNull);
        expect(vm.ruolo, 'RAGAZZO');
        expect(vm.squadriglia, 'Volpi');
        expect(vm.isValid, isFalse);
        expect(repo.aggiunti.single.squadriglia, 'Volpi');
        expect(repo.aggiunti.single.ruolo, 'VICE_CAPO_SQ');
      },
    );

    test('una data di nascita nel futuro non è valida, quella di oggi sì', () {
      final vm = costruisci();
      vm.setNome('Giulia');
      vm.setCognome('Rossi');

      vm.setDataNascita(DateTime(2026, 11, 17));
      expect(vm.erroreDataNascita, isNotNull);
      expect(vm.isValid, isFalse);

      vm.setDataNascita(DateTime(2026, 11, 16));
      expect(vm.erroreDataNascita, isNull);
      expect(vm.isValid, isTrue);
    });

    test('toccare la squadriglia già scelta la toglie', () {
      final vm = costruisci();
      vm.setSquadriglia('Aquile');
      vm.setSquadriglia('aquile');
      expect(vm.squadriglia, isEmpty);
    });

    test('un ruolo che non è da ragazzo viene ignorato', () {
      final vm = costruisci();
      vm.setRuolo('CAPO_UNITA');
      expect(vm.ruolo, 'RAGAZZO');
    });

    test(
      "un errore di salvataggio arriva alla View e non conta l'aggiunta",
      () async {
        repo.erroreScrittura = const JambException(
          TipoErrore.permessoNegato,
          'No',
        );
        final vm = costruisci();
        vm.setNome('Giulia');
        vm.setCognome('Rossi');

        await expectLater(vm.salva(), throwsA(isA<JambException>()));
        expect(vm.aggiunti, 0);
      },
    );

    test(
      'se le squadriglie non arrivano si può aggiungere lo stesso',
      () async {
        repo.erroreLettura = const JambException(
          TipoErrore.rete,
          'Nessuna connessione',
        );
        final vm = costruisci();
        await Future.delayed(Duration.zero);
        expect(vm.haErrore, isTrue);
        expect(vm.squadriglie, isEmpty);

        vm.setNome('Giulia');
        vm.setCognome('Rossi');
        await vm.salva();
        expect(repo.aggiunti, hasLength(1));
      },
    );
  });
}
