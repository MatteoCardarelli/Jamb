import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/campo/view_model/campo_view_model.dart';
import 'package:jamb/ui/campo/widgets/campo_screen.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_campo_repository.dart';

const _campo = Campo(id: 'campo', titolo: 'Estivo');

CompitoCampo _c(StatoCompito stato) =>
    CompitoCampo(id: stato.name, pattugliaId: 'p', titolo: stato.name, stato: stato);

void main() {
  group('StatoCompito', () {
    test('il ciclo torna all\'inizio dopo «Fatto»', () {
      expect(StatoCompito.daFare.prossimo, StatoCompito.inCorso);
      expect(StatoCompito.inCorso.prossimo, StatoCompito.fatto);
      expect(StatoCompito.fatto.prossimo, StatoCompito.daFare);
    });

    test('un valore sconosciuto del DB degrada a «Da fare»', () {
      expect(StatoCompito.daDb('bloccato'), StatoCompito.daFare);
    });

    test('i valori coincidono con il vincolo della migrazione', () {
      final migrazione = Directory('../supabase/migrations')
          .listSync()
          .whereType<File>()
          .singleWhere((f) => f.path.endsWith('_programmazione_campo.sql'))
          .readAsStringSync();
      for (final s in StatoCompito.values) {
        expect(migrazione, contains("'${s.valoreDb}'"));
      }
    });
  });

  group('AvanzamentoCampo', () {
    test('conta solo i compiti fatti, non quelli in corso', () {
      final a = AvanzamentoCampo.di([_c(StatoCompito.fatto), _c(StatoCompito.inCorso), _c(StatoCompito.daFare)]);
      expect(a.fatti, 1);
      expect(a.totali, 3);
      expect(a.frazione, closeTo(1 / 3, 0.0001));
    });

    test('senza compiti la frazione è zero, non un errore', () {
      expect(AvanzamentoCampo.di(const []).frazione, 0);
    });
  });

  group('CampoViewModel', () {
    Future<(FakeCampoRepository, CampoViewModel)> crea({Campo? campo}) async {
      final repo = FakeCampoRepository(campo: campo);
      final vm = CampoViewModel(repo);
      await pumpEventQueue();
      return (repo, vm);
    }

    test('senza campo mostra lo stato vuoto, poi lo crea', () async {
      final (_, vm) = await crea();
      expect(vm.campo, isNull);
      await vm.creaCampo('Estivo');
      await pumpEventQueue();
      expect(vm.campo?.titolo, 'Estivo');
    });

    test('i compiti restano con la propria pattuglia', () async {
      final (_, vm) = await crea(campo: _campo);
      await vm.creaPattuglia('Cucina');
      await pumpEventQueue();
      await vm.creaPattuglia('Logistica');
      await pumpEventQueue();
      await vm.creaCompito(vm.pattuglie.first, 'Menu');
      await pumpEventQueue();
      expect(vm.compitiDi(vm.pattuglie.first).single.titolo, 'Menu');
      expect(vm.compitiDi(vm.pattuglie.last), isEmpty);
    });

    test('avanzare lo stato aggiorna il conteggio', () async {
      final (_, vm) = await crea(campo: _campo);
      await vm.creaPattuglia('Cucina');
      await pumpEventQueue();
      await vm.creaCompito(vm.pattuglie.single, 'Menu');
      await pumpEventQueue();
      final p = vm.pattuglie.single;
      await vm.avanzaStato(vm.compitiDi(p).single);
      await pumpEventQueue();
      expect(vm.avanzamento.fatti, 0);
      await vm.avanzaStato(vm.compitiDi(p).single);
      await pumpEventQueue();
      expect(vm.avanzamento.fatti, 1);
      expect(vm.avanzamentoDi(p).fatti, 1);
    });

    test('eliminare una pattuglia toglie i suoi compiti dai conteggi', () async {
      final (_, vm) = await crea(campo: _campo);
      await vm.creaPattuglia('Cucina');
      await pumpEventQueue();
      await vm.creaCompito(vm.pattuglie.single, 'Menu');
      await pumpEventQueue();
      await vm.eliminaPattuglia(vm.pattuglie.single);
      await pumpEventQueue();
      expect(vm.avanzamento.totali, 0);
    });

    test('cambiare il luogo non perde titolo e date', () async {
      final (_, vm) = await crea(
        campo: Campo(id: 'c', titolo: 'Estivo', dataInizio: DateTime(2027, 7, 1), dataFine: DateTime(2027, 7, 8)),
      );
      await vm.impostaLuogo('Val di Fassa');
      await pumpEventQueue();
      expect(vm.campo!.titolo, 'Estivo');
      expect(vm.campo!.dataFine, DateTime(2027, 7, 8));
      expect(vm.campo!.luogo, 'Val di Fassa');
    });

    test('un errore di lettura diventa uno stato di errore', () async {
      final repo = FakeCampoRepository()
        ..erroreLettura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = CampoViewModel(repo);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  test('un testo vuoto non è valido', () {
    expect(erroreTestoCampo('  '), isNotNull);
    expect(erroreTestoCampo('Cucina'), isNull);
  });

  testWidgets('senza campo propone di prepararlo', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => CampoViewModel(FakeCampoRepository()),
      child: const MaterialApp(home: CampoView()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Prepara il campo'), findsOneWidget);
    expect(find.text('Nuova pattuglia'), findsNothing);
  });
}
