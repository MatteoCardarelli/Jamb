import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/bacheca/view_model/bacheca_view_model.dart';
import 'package:jamb/ui/bacheca/view_model/dettaglio_avviso_view_model.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';
import '../../testing/fakes/fake_avviso_repository.dart';
import '../../testing/models/avviso_di_test.dart';

/// Attende il caricamento avviato nel costruttore o da una notifica.
Future<void> _attendi() => Future.delayed(Duration.zero);

void main() {
  group('BachecaViewModel', () {
    test('mostra gli avvisi dal più recente', () async {
      final vm = BachecaViewModel(FakeAvvisoRepository([
        avvisoDiTest('vecchio', giorno: 1),
        avvisoDiTest('nuovo', giorno: 20),
        avvisoDiTest('medio', giorno: 10),
      ]));
      await _attendi();

      expect(vm.avvisi.map((a) => a.id), ['nuovo', 'medio', 'vecchio']);
    });

    test('il filtro per destinatari è esatto', () async {
      final vm = BachecaViewModel(FakeAvvisoRepository([
        avvisoDiTest('unita'),
        avvisoDiTest('aquile', squadriglia: 'Aquile'),
        avvisoDiTest('orsi', squadriglia: 'Orsi'),
      ]));
      await _attendi();

      vm.setFiltro(FiltroAvvisi.unita);
      expect(vm.avvisi.map((a) => a.id), ['unita']);

      vm.setFiltro(const FiltroAvvisi.squadriglia('Aquile'));
      expect(vm.avvisi.map((a) => a.id), ['aquile']);

      vm.setFiltro(FiltroAvvisi.tutti);
      expect(vm.avvisi, hasLength(3));
    });

    test('i filtri elencano solo le squadriglie con avvisi, in ordine', () async {
      final vm = BachecaViewModel(FakeAvvisoRepository([
        avvisoDiTest('a', squadriglia: 'Orsi'),
        avvisoDiTest('b', squadriglia: 'Aquile'),
        avvisoDiTest('c', squadriglia: 'Orsi'),
      ]));
      await _attendi();

      expect(vm.filtri.map((f) => f.etichetta),
          ['Tutti', "Tutta l'unità", 'Aquile', 'Orsi']);
    });

    // La campanella deve contare tutti i non letti, anche quelli nascosti
    // dal filtro scelto nella bacheca.
    test('i non letti si contano su tutta la bacheca, non sul filtro', () async {
      final vm = BachecaViewModel(FakeAvvisoRepository([
        avvisoDiTest('a'),
        avvisoDiTest('b', squadriglia: 'Aquile'),
        avvisoDiTest('c', squadriglia: 'Aquile', letto: true),
      ]));
      await _attendi();

      vm.setFiltro(FiltroAvvisi.unita);
      expect(vm.nonLetti, 2);
    });

    test('se la squadriglia filtrata non ha più avvisi torna a «Tutti»', () async {
      final repo = FakeAvvisoRepository([
        avvisoDiTest('a'),
        avvisoDiTest('b', squadriglia: 'Aquile'),
      ]);
      final vm = BachecaViewModel(repo);
      await _attendi();
      vm.setFiltro(const FiltroAvvisi.squadriglia('Aquile'));

      repo.data.removeWhere((a) => a.id == 'b');
      repo.notifyListeners();
      await _attendi();

      expect(vm.filtro, FiltroAvvisi.tutti);
      expect(vm.avvisi.map((a) => a.id), ['a']);
    });

    test('un errore di lettura porta allo stato errore', () async {
      final vm = BachecaViewModel(FakeAvvisoRepository(
        [avvisoDiTest('a')],
        erroreLettura: const JambException(TipoErrore.rete, 'Connessione assente.'),
      ));
      await _attendi();

      expect(vm.stato, StatoCaricamento.errore);
      expect(vm.errore, 'Connessione assente.');
    });
  });

  group('DettaglioAvvisoViewModel', () {
    test('aprire un avviso non letto lo segna e aggiorna i non letti', () async {
      final repo = FakeAvvisoRepository([avvisoDiTest('a'), avvisoDiTest('b')]);
      final bacheca = BachecaViewModel(repo);
      await _attendi();
      expect(bacheca.nonLetti, 2);

      DettaglioAvvisoViewModel(repo.data.first, repo);
      await _attendi();

      expect(repo.letti, ['a']);
      expect(bacheca.nonLetti, 1);
    });

    test('aprire un avviso già letto non scrive nulla', () async {
      final repo = FakeAvvisoRepository([avvisoDiTest('a', letto: true)]);
      DettaglioAvvisoViewModel(repo.data.first, repo);
      await _attendi();

      expect(repo.letti, isEmpty);
    });

    test('se la lettura non si registra il dettaglio resta utilizzabile', () async {
      final repo = FakeAvvisoRepository(
        [avvisoDiTest('a')],
        erroreScrittura: const JambException(TipoErrore.rete, 'Connessione assente.'),
      );
      final vm = DettaglioAvvisoViewModel(repo.data.first, repo);
      await _attendi();

      expect(vm.avviso.id, 'a');
      expect(vm.destinatari, "Tutta l'unità");
    });
  });
}
