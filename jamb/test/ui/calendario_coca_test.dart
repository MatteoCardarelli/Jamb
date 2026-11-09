import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/permessi.dart';
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
  final altra = eventoDiTest('altra', giorno, livello: LivelloEvento.altraUnita);

  group('FiltroCalendario', () {
    // La scelta dell'utente: ogni capo vede gli eventi di ogni branca.
    test('«Tutti» include anche le altre unità', () {
      expect([unita, coca, gruppo, altra].where(FiltroCalendario.tutti.include), hasLength(4));
    });

    test('«La mia unità» esclude Co.Ca., gruppo e altre unità', () {
      expect([unita, coca, gruppo, altra].where(FiltroCalendario.unita.include), [unita]);
    });

    test('«Co.Ca.» comprende gli eventi di gruppo ma non le altre unità', () {
      expect([unita, coca, gruppo, altra].where(FiltroCalendario.coca.include), [coca, gruppo]);
    });
  });

  group('Evento.etichettaLivello', () {
    test('un evento della propria unità non ha etichetta', () {
      expect(unita.etichettaLivello, isEmpty);
    });

    test('un evento di un\'altra unità mostra il nome dell\'unità', () {
      expect(altra.copyWith(nomeUnita: 'Amici del Velino').etichettaLivello, 'Amici del Velino');
    });

    test('senza nome dell\'unità resta riconoscibile', () {
      expect(altra.etichettaLivello, 'Altra unità');
    });
  });

  group('Permessi.puoModificareEvento', () {
    const aiutoCapo = Permessi(ruolo: 'AIUTO_CAPO');
    const capoGruppo = Permessi(ruolo: 'CAPO_UNITA', capoGruppo: true);

    test('un capo modifica gli eventi della sua unità e della Co.Ca.', () {
      expect(aiutoCapo.puoModificareEvento(LivelloEvento.unita), isTrue);
      expect(aiutoCapo.puoModificareEvento(LivelloEvento.coca), isTrue);
    });

    // La policy toccherebbe zero righe senza dare errore: l'azione non si offre.
    test('un capo non modifica gli eventi di un\'altra unità o di gruppo', () {
      expect(aiutoCapo.puoModificareEvento(LivelloEvento.altraUnita), isFalse);
      expect(aiutoCapo.puoModificareEvento(LivelloEvento.gruppo), isFalse);
    });

    test('il Capo Gruppo li modifica tutti', () {
      for (final livello in LivelloEvento.values) {
        expect(capoGruppo.puoModificareEvento(livello), isTrue);
      }
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

  group('letture del calendario', () {
    // Ogni tocco su un giorno scaricava tre volte tutti gli eventi.
    test('l\'apertura legge gli eventi una sola volta', () async {
      final repo = FakeEventoRepository(eventi: [unita]);
      CalendarioViewModel(repo);
      await pumpEventQueue();
      expect(repo.letture, 1);
    });

    test('cambiare giorno e filtro non richiede nulla al server', () async {
      final repo = FakeEventoRepository(eventi: [unita]);
      final vm = CalendarioViewModel(repo);
      await pumpEventQueue();

      vm.setSelectedDate(giorno.add(const Duration(days: 1)));
      await pumpEventQueue();
      expect(vm.eventiDelGiorno, isEmpty);

      vm.setSelectedDate(giorno);
      vm.setFiltro(FiltroCalendario.coca);
      await pumpEventQueue();

      expect(repo.letture, 1);
    });
  });

  group('eventoNelGiorno', () {
    final campo = eventoDiTest('campo', DateTime(2026, 7, 1, 18), fine: DateTime(2026, 7, 8, 10));

    test('vale dal primo all\'ultimo giorno, a qualunque ora', () {
      expect(eventoNelGiorno(campo, DateTime(2026, 7, 1, 2)), isTrue);
      expect(eventoNelGiorno(campo, DateTime(2026, 7, 4)), isTrue);
      expect(eventoNelGiorno(campo, DateTime(2026, 7, 8, 23)), isTrue);
    });

    test('non vale il giorno prima né quello dopo', () {
      expect(eventoNelGiorno(campo, DateTime(2026, 6, 30, 23)), isFalse);
      expect(eventoNelGiorno(campo, DateTime(2026, 7, 9)), isFalse);
    });
  });

  group('eventiProssimi', () {
    final oggiFisso = DateTime(2026, 11, 9, 15);

    test('da domani per due settimane, non oggi', () {
      final eventi = [
        eventoDiTest('oggi', DateTime(2026, 11, 9, 20)),
        eventoDiTest('domani', DateTime(2026, 11, 10)),
        eventoDiTest('ultimo', DateTime(2026, 11, 24)),
        eventoDiTest('oltre', DateTime(2026, 11, 25, 9)),
      ];
      expect(eventiProssimi(eventi, oggiFisso).map((e) => e.id), ['domani', 'ultimo']);
    });
  });

  group('eventoPerAppello', () {
    test('ignora un evento di Co.Ca. in corso e prende quello dell\'unità', () {
      final adesso = DateTime(2026, 11, 8, 10, 30);
      final inCorsoCoca = eventoDiTest('coca', DateTime(2026, 11, 8, 10), livello: LivelloEvento.coca);
      final imminente = eventoDiTest('unita', DateTime(2026, 11, 8, 11));
      expect(eventoPerAppello([inCorsoCoca, imminente], adesso)?.id, 'unita');
    });

    test('ignora un evento in corso di un\'altra unità', () {
      final adesso = DateTime(2026, 11, 8, 10, 30);
      final inCorso = eventoDiTest('altra', DateTime(2026, 11, 8, 10), livello: LivelloEvento.altraUnita);
      expect(eventoPerAppello([inCorso], adesso), isNull);
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
      expect(SupabaseEventoRepository.livelloDaDb(null, null, 'attiva'), LivelloEvento.gruppo);
    });

    test('l\'unità COCA è la Co.Ca.', () {
      expect(
        SupabaseEventoRepository.livelloDaDb('u', {'tipo_branca': 'COCA'}, 'attiva'),
        LivelloEvento.coca,
      );
    });

    test('l\'unità attiva è la propria, qualunque sia la branca', () {
      expect(
        SupabaseEventoRepository.livelloDaDb('attiva', {'tipo_branca': 'NUOVO'}, 'attiva'),
        LivelloEvento.unita,
      );
    });

    test('un\'altra unità resta in sola lettura', () {
      expect(
        SupabaseEventoRepository.livelloDaDb('u', {'tipo_branca': 'RS'}, 'attiva'),
        LivelloEvento.altraUnita,
      );
      expect(SupabaseEventoRepository.livelloDaDb('u', null, 'attiva'), LivelloEvento.altraUnita);
    });
  });
}
