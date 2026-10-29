import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/bacheca/view_model/form_avviso_view_model.dart';
import '../../testing/fakes/fake_avviso_repository.dart';
import '../../testing/fakes/fake_scout_repository.dart';
import '../../testing/models/avviso_di_test.dart';
import '../../testing/models/scout_di_test.dart';

void main() {
  late FakeAvvisoRepository avvisi;
  late FakeScoutRepository scout;

  setUp(() {
    avvisi = FakeAvvisoRepository([]);
    scout = FakeScoutRepository([
      scoutDiTest('Andrea', 'Orsi'),
      scoutDiTest('Luca', 'Aquile'),
    ]);
  });

  group('FormAvvisoViewModel', () {
    test('un oggetto di soli spazi non è valido e non scrive nulla', () async {
      final vm = FormAvvisoViewModel(avvisi, scout)
        ..setTitolo('   ')
        ..setContenuto('Alle 15 in sede');

      expect(vm.isValid, isFalse);
      expect(await vm.salva(), isNull);
      expect(avvisi.creati, isEmpty);
    });

    test('un nuovo avviso si pubblica con i testi ripuliti e i destinatari', () async {
      final vm = FormAvvisoViewModel(avvisi, scout)
        ..setTitolo('  Ritrovo ')
        ..setContenuto(' Alle 15 in sede ')
        ..setSquadriglia('Aquile');

      await vm.salva();

      expect(avvisi.creati, hasLength(1));
      expect(avvisi.creati.single.titolo, 'Ritrovo');
      expect(avvisi.creati.single.contenuto, 'Alle 15 in sede');
      expect(avvisi.creati.single.squadriglia, 'Aquile');
      expect(avvisi.aggiornati, isEmpty);
    });

    test('la modifica aggiorna lo stesso avviso, anche tornando a tutta l\'unità', () async {
      final esistente = avvisoDiTest('x', squadriglia: 'Orsi');
      final vm = FormAvvisoViewModel(avvisi, scout, avvisoEsistente: esistente)
        ..setSquadriglia(null);

      await vm.salva();

      expect(avvisi.creati, isEmpty);
      expect(avvisi.aggiornati.single.id, 'x');
      expect(avvisi.aggiornati.single.squadriglia, isNull);
      expect(avvisi.aggiornati.single.dataPubblicazione, esistente.dataPubblicazione);
    });

    test('le squadriglie sono in ordine e includono quella già scelta', () async {
      final esistente = avvisoDiTest('x', squadriglia: 'Volpi'); // disattivata
      final vm = FormAvvisoViewModel(avvisi, scout, avvisoEsistente: esistente);
      await Future.delayed(Duration.zero);

      expect(vm.squadriglieDisponibili, ['Aquile', 'Orsi', 'Volpi']);
    });

    test('un errore di salvataggio arriva alla View', () async {
      avvisi.erroreScrittura =
          const JambException(TipoErrore.permessoNegato, 'Operazione non consentita.');
      final vm = FormAvvisoViewModel(avvisi, scout)
        ..setTitolo('Ritrovo')
        ..setContenuto('Alle 15');

      expect(vm.salva(), throwsA(isA<JambException>()));
    });
  });
}
