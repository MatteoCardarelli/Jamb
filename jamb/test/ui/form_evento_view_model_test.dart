import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/categoria_evento_colori.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/ui/calendario/view_model/form_evento_view_model.dart';
import '../../testing/fakes/fake_evento_repository.dart';
import '../../testing/fakes/fake_obiettivo_repository.dart';

FormEventoViewModel _vm(
  FakeEventoRepository eventi, {
  Evento? eventoEsistente,
  DateTime? giorno,
  DateTime? adesso,
  List<String> domini = const ['Servizio'],
}) =>
    FormEventoViewModel(
      eventi,
      FakeObiettivoRepository(domini),
      eventoEsistente: eventoEsistente,
      giorno: giorno,
      adesso: adesso,
    );

void _compila(FormEventoViewModel vm) {
  vm.setTitolo('Uscita');
  vm.setLuogo('Campo Imperatore');
  vm.toggleCategoria(categoriaAltro);
}

void main() {
  group('FormEventoViewModel', () {
    // Richiesta dal collaudo: prima il form partiva sempre da oggi.
    test('un nuovo evento parte dal giorno selezionato, all\'ora attuale', () {
      final vm = _vm(
        FakeEventoRepository(),
        giorno: DateTime(2026, 11, 7),
        adesso: DateTime(2026, 10, 29, 15, 42),
      );
      expect(vm.dataInizio, DateTime(2026, 11, 7, 15, 42));
      expect(vm.dataFine, DateTime(2026, 11, 7, 16, 42));
    });

    // I filtri del calendario confrontano le date: un evento di giornata
    // intera deve coprire tutto il primo e tutto l'ultimo giorno.
    test('la giornata intera salva dalle 00:00 del primo giorno alle 23:59 dell\'ultimo', () async {
      final eventi = FakeEventoRepository();
      final vm = _vm(eventi, giorno: DateTime(2026, 11, 7), adesso: DateTime(2026, 10, 29, 15, 42));
      _compila(vm);
      vm.setTuttoIlGiorno(true);
      vm.setDataFine(DateTime(2026, 11, 8, 9, 0));

      await vm.salvaEvento();

      final salvato = eventi.creati.single;
      expect(salvato.tuttoIlGiorno, isTrue);
      expect(salvato.dataInizio, DateTime(2026, 11, 7));
      expect(salvato.dataFine, DateTime(2026, 11, 8, 23, 59));
    });

    // Con orari, fine prima dell'inizio non è valida; con la giornata
    // intera conta solo il giorno, quindi lo stesso giorno è valido.
    test('la giornata intera rende valido un evento che finisce lo stesso giorno', () {
      final vm = _vm(FakeEventoRepository(), giorno: DateTime(2026, 11, 7), adesso: DateTime(2026, 10, 29, 15, 42));
      _compila(vm);
      vm.setDataFine(DateTime(2026, 11, 7, 9, 0));
      expect(vm.isValid, isFalse);

      vm.setTuttoIlGiorno(true);
      expect(vm.isValid, isTrue);
    });

    test('in modifica aggiorna l\'evento esistente con lo stesso id invece di crearne uno', () async {
      final eventi = FakeEventoRepository();
      final esistente = Evento(
        id: 'evento-1',
        titolo: 'Riunione',
        dataInizio: DateTime(2026, 11, 7, 15),
        dataFine: DateTime(2026, 11, 7, 17),
        luogo: 'Sede',
        categorie: const ['Servizio'],
        colorePrincipale: const Color(0xFF1D2660),
      );
      final vm = _vm(eventi, eventoEsistente: esistente);
      vm.setTitolo('Riunione di squadriglia');

      await vm.salvaEvento();

      expect(eventi.creati, isEmpty);
      expect(eventi.aggiornati.single.id, 'evento-1');
      expect(eventi.aggiornati.single.titolo, 'Riunione di squadriglia');
    });

    // Se un dominio del Programma è stato rinominato, la vecchia categoria
    // dell'evento deve restare visibile per poterla togliere.
    test('le categorie già assegnate restano selezionabili anche se non più tra i domini', () async {
      final esistente = Evento(
        id: 'evento-1',
        titolo: 'Riunione',
        dataInizio: DateTime(2026, 11, 7, 15),
        dataFine: DateTime(2026, 11, 7, 17),
        luogo: 'Sede',
        categorie: const ['Vecchio dominio'],
        colorePrincipale: const Color(0xFF1D2660),
      );
      final vm = _vm(FakeEventoRepository(), eventoEsistente: esistente, domini: ['Servizio']);
      await Future.delayed(Duration.zero);

      expect(vm.categorieDisponibili, ['Servizio', 'Vecchio dominio', categoriaAltro]);
    });
  });

  group('FormEventoViewModel — si ripete', () {
    FormEventoViewModel nuovo(FakeEventoRepository repo) => _vm(
          repo,
          giorno: DateTime(2026, 11, 7),
          adesso: DateTime(2026, 11, 7, 15),
        )..setTitolo('Riunione')..setLuogo('Sede')..toggleCategoria(categoriaAltro);

    test('la fine proposta è il 31 agosto dell\'anno scout', () {
      expect(nuovo(FakeEventoRepository()).finoAl, DateTime(2027, 8, 31));
    });

    test('l\'anteprima conta gli eventi che verranno creati', () {
      final vm = nuovo(FakeEventoRepository())
        ..setRipetizione(Ripetizione.ogniSettimana)
        ..setFinoAl(DateTime(2026, 11, 28));
      expect(vm.numeroEventi, 4);
    });

    test('salva la ripetizione e la data di fine scelte', () async {
      final repo = FakeEventoRepository();
      final vm = nuovo(repo)
        ..setRipetizione(Ripetizione.ogniMese)
        ..setFinoAl(DateTime(2027, 6, 30));

      await vm.salvaEvento();

      expect(repo.ripetizioni.single.ripetizione, Ripetizione.ogniMese);
      expect(repo.ripetizioni.single.finoAl, DateTime(2027, 6, 30));
    });

    // Con la fine prima dell'inizio non nascerebbe nessun evento: il
    // salvataggio non deve sembrare riuscito.
    test('una fine prima dell\'inizio rende il form non valido', () async {
      final repo = FakeEventoRepository();
      final vm = nuovo(repo)
        ..setRipetizione(Ripetizione.ogniGiorno)
        ..setFinoAl(DateTime(2026, 11, 1));

      expect(vm.isValid, isFalse);
      expect(await vm.salvaEvento(), isNull);
      expect(repo.creati, isEmpty);
    });

    test('spostando l\'inizio oltre la fine, la fine torna al 31 agosto', () {
      final vm = nuovo(FakeEventoRepository())..setFinoAl(DateTime(2026, 11, 20));
      vm.setDataInizio(DateTime(2026, 12, 5, 15));
      expect(vm.finoAl, DateTime(2027, 8, 31));
    });

    test('modificando un evento della serie conserva la serie e passa la scelta', () async {
      final repo = FakeEventoRepository();
      final esistente = Evento(
        id: 'e1',
        titolo: 'Riunione',
        dataInizio: DateTime(2026, 11, 14, 15),
        dataFine: DateTime(2026, 11, 14, 17),
        luogo: 'Sede',
        categorie: const [categoriaAltro],
        colorePrincipale: Colors.grey,
        serieId: 'serie',
        ripetizione: Ripetizione.ogniSettimana,
      );
      final vm = _vm(repo, eventoEsistente: esistente)..setLuogo('Bosco');

      expect(vm.inSerie, isTrue);
      await vm.salvaEvento(ambito: AmbitoSerie.questoESuccessivi);

      expect(repo.aggiornati.single.serieId, 'serie');
      expect(repo.aggiornati.single.luogo, 'Bosco');
      expect(repo.ambitiAggiornamento.single, AmbitoSerie.questoESuccessivi);
    });
  });
}
