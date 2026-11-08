import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/repositories/supabase_evento_repository.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/ui/calendario/view_model/calendario_view_model.dart';
import 'package:jamb/ui/calendario/view_model/form_evento_view_model.dart';
import '../../testing/fakes/fake_evento_repository.dart';
import '../../testing/fakes/fake_obiettivo_repository.dart';
import '../../testing/models/evento_di_test.dart';

void main() {
  final oggi = DateTime.now();
  final giorno = DateTime(oggi.year, oggi.month, oggi.day, 10);
  final unita = eventoDiTest('unita', giorno);
  final coca = eventoDiTest('coca', giorno, livello: LivelloEvento.coca);
  final gruppo = eventoDiTest('gruppo', giorno, livello: LivelloEvento.gruppo);

  group('FiltroCalendario', () {
    test('«Tutti» include ogni livello', () {
      expect([unita, coca, gruppo].where(FiltroCalendario.tutti.include), hasLength(3));
    });

    test('«La mia unità» esclude Co.Ca. e gruppo', () {
      expect([unita, coca, gruppo].where(FiltroCalendario.unita.include), [unita]);
    });

    test('«Co.Ca.» comprende anche gli eventi di gruppo', () {
      expect([unita, coca, gruppo].where(FiltroCalendario.coca.include), [coca, gruppo]);
    });
  });

  group('CalendarioViewModel', () {
    test('il filtro vale per il giorno, i prossimi eventi e i marker', () async {
      final domani = giorno.add(const Duration(days: 2));
      final vm = CalendarioViewModel(FakeEventoRepository(eventi: [
        unita,
        coca,
        eventoDiTest('prossimo-unita', domani),
        eventoDiTest('prossimo-coca', domani, livello: LivelloEvento.coca),
      ]));
      await pumpEventQueue();

      expect(vm.eventiDelGiorno, hasLength(2));

      vm.setFiltro(FiltroCalendario.coca);

      expect(vm.eventiDelGiorno.map((e) => e.id), ['coca']);
      expect(vm.prossimiEventi.map((e) => e.id), ['prossimo-coca']);
      expect(vm.getEventiForDay(giorno).map((e) => e.id), ['coca']);
    });
  });

  group('eventoPerAppello', () {
    test('ignora un evento di Co.Ca. in corso e prende quello dell\'unità', () {
      final adesso = DateTime(2026, 11, 8, 10, 30);
      final inCorsoCoca = eventoDiTest('coca', DateTime(2026, 11, 8, 10), livello: LivelloEvento.coca);
      final imminente = eventoDiTest('unita', DateTime(2026, 11, 8, 11));
      expect(eventoPerAppello([inCorsoCoca, imminente], adesso)?.id, 'unita');
    });

    test('con i soli eventi di Co.Ca. non propone nessun appello', () {
      final adesso = DateTime(2026, 11, 8, 10, 30);
      final inCorso = eventoDiTest('coca', DateTime(2026, 11, 8, 10), livello: LivelloEvento.coca);
      expect(eventoPerAppello([inCorso], adesso), isNull);
    });
  });

  group('FormEventoViewModel', () {
    FormEventoViewModel crea(FakeEventoRepository repo, {Evento? esistente}) => FormEventoViewModel(
          repo,
          FakeObiettivoRepository(const []),
          eventoEsistente: esistente,
          adesso: DateTime(2026, 11, 8, 10),
        );

    test('un nuovo evento è dell\'unità, salvo scelta diversa', () async {
      final repo = FakeEventoRepository();
      final vm = crea(repo)
        ..setTitolo('Consiglio')
        ..setLuogo('Sede')
        ..toggleCategoria('Altro')
        ..setLivello(LivelloEvento.coca);
      await pumpEventQueue();

      await vm.salvaEvento();

      expect(repo.creati.single.livello, LivelloEvento.coca);
    });

    test('in modifica un evento di Co.Ca. resta di Co.Ca.', () async {
      final repo = FakeEventoRepository();
      final vm = crea(repo, esistente: coca);
      await pumpEventQueue();

      await vm.salvaEvento();

      expect(repo.aggiornati.single.livello, LivelloEvento.coca);
    });
  });

  group('SupabaseEventoRepository.livelloDaDb', () {
    test('senza unità è di gruppo', () {
      expect(SupabaseEventoRepository.livelloDaDb(null, null), LivelloEvento.gruppo);
    });

    test('l\'unità COCA è la Co.Ca.', () {
      expect(
        SupabaseEventoRepository.livelloDaDb('u', {'tipo_branca': 'COCA'}),
        LivelloEvento.coca,
      );
    });

    test('un tipo sconosciuto degrada a evento di unità', () {
      expect(SupabaseEventoRepository.livelloDaDb('u', {'tipo_branca': 'NUOVO'}), LivelloEvento.unita);
      expect(SupabaseEventoRepository.livelloDaDb('u', null), LivelloEvento.unita);
    });
  });
}
