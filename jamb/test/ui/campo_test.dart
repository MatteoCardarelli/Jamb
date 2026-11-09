import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/campo/view_model/campo_view_model.dart';
import 'package:jamb/ui/campo/widgets/campi_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_riga_contatto.dart';
import 'package:provider/provider.dart';
import '../../testing/fakes/fake_campo_repository.dart';

const _campo = Campo(id: 'campo', titolo: 'Estivo', tipo: TipoCampo.campoEstivo);
const _anna = MembroUnita(id: 'a', nome: 'Anna', ruolo: 'CAPO_UNITA');
const _bruno = MembroUnita(id: 'b', nome: 'Bruno', ruolo: 'AIUTO_CAPO');

CompitoCampo _c(StatoCompito stato) =>
    CompitoCampo(id: stato.name, pattugliaId: 'p', titolo: stato.name, stato: stato);

String _migrazione(String fine) => Directory('../supabase/migrations')
    .listSync()
    .whereType<File>()
    .singleWhere((f) => f.path.endsWith(fine))
    .readAsStringSync();

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
      final sql = _migrazione('_programmazione_campo.sql');
      for (final s in StatoCompito.values) {
        expect(sql, contains("'${s.valoreDb}'"));
      }
    });
  });

  group('TipoCampo', () {
    test('il Reparto sceglie tra i suoi momenti forti', () {
      expect(TipoCampo.perBranca('EG'), [
        TipoCampo.campoInvernale,
        TipoCampo.sanGiorgio,
        TipoCampo.campoEstivo,
        TipoCampo.uscita,
      ]);
    });

    test('Branco e Clan hanno i loro', () {
      expect(TipoCampo.perBranca('LC'), [TipoCampo.vacanzeBranco, TipoCampo.uscita]);
      expect(
        TipoCampo.perBranca('RS'),
        [TipoCampo.routeEstiva, TipoCampo.routeInvernale, TipoCampo.uscita],
      );
    });

    test('ogni branca può sempre creare un\'uscita generica', () {
      for (final b in ['EG', 'LC', 'RS', 'COCA', null]) {
        expect(TipoCampo.perBranca(b), contains(TipoCampo.uscita));
      }
    });

    test('un valore sconosciuto del DB degrada a uscita', () {
      expect(TipoCampo.daDb('gemellaggio'), TipoCampo.uscita);
    });

    test('i valori coincidono con il vincolo della migrazione', () {
      final sql = _migrazione('_organizzazione_campo.sql');
      for (final t in TipoCampo.values) {
        expect(sql, contains("'${t.valoreDb}'"));
      }
    });
  });

  group('erroreTelefono', () {
    test('accetta spazi, trattini e prefisso internazionale', () {
      expect(erroreTelefono('333 1234567'), isNull);
      expect(erroreTelefono('+39 333-1234567'), isNull);
      expect(erroreTelefono('112'), isNull);
    });

    test('rifiuta testo e numeri vuoti', () {
      expect(erroreTelefono('  '), isNotNull);
      expect(erroreTelefono('chiamami'), isNotNull);
      expect(erroreTelefono('12'), isNotNull);
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

  group('CampiViewModel', () {
    test('più campi convivono nello stesso anno', () async {
      final vm = CampiViewModel(FakeCampoRepository(), tipi: TipoCampo.perBranca('EG'));
      await pumpEventQueue();
      await vm.crea(TipoCampo.campoInvernale, 'Inverno');
      await pumpEventQueue();
      final estivo = await vm.crea(TipoCampo.campoEstivo, 'Estate');
      await pumpEventQueue();
      expect(vm.campi, hasLength(2));
      expect(estivo.tipo, TipoCampo.campoEstivo);
    });

    test('un errore di lettura diventa uno stato di errore', () async {
      final repo = FakeCampoRepository()
        ..erroreLettura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = CampiViewModel(repo, tipi: const [TipoCampo.uscita]);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  group('CampoViewModel', () {
    Future<(FakeCampoRepository, CampoViewModel)> crea() async {
      final repo = FakeCampoRepository(campi: [_campo], staff: [_anna, _bruno]);
      final vm = CampoViewModel(repo, _campo.id);
      await pumpEventQueue();
      return (repo, vm);
    }

    Future<Pattuglia> conPattuglia(CampoViewModel vm) async {
      await vm.creaPattuglia('Cucina');
      await pumpEventQueue();
      return vm.pattuglie.single;
    }

    test('i compiti restano con la propria pattuglia', () async {
      final (_, vm) = await crea();
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
      final (_, vm) = await crea();
      final p = await conPattuglia(vm);
      await vm.creaCompito(p, 'Menu');
      await pumpEventQueue();
      await vm.avanzaStato(vm.compitiDi(p).single);
      await pumpEventQueue();
      expect(vm.avanzamento.fatti, 0);
      await vm.avanzaStato(vm.compitiDi(p).single);
      await pumpEventQueue();
      expect(vm.avanzamento.fatti, 1);
      expect(vm.avanzamentoDi(p).fatti, 1);
    });

    test('i componenti sono quelli scelti tra lo staff', () async {
      final (_, vm) = await crea();
      final p = await conPattuglia(vm);
      await vm.salvaMembri(p, {'b'});
      await pumpEventQueue();
      expect(vm.membriDi(vm.pattuglie.single), [_bruno]);
    });

    test('chi ha lasciato lo staff non compare tra i componenti', () async {
      final (_, vm) = await crea();
      final p = await conPattuglia(vm);
      await vm.salvaMembri(p, {'a', 'uscito'});
      await pumpEventQueue();
      expect(vm.membriDi(vm.pattuglie.single), [_anna]);
    });

    test('rinominare una pattuglia non perde i componenti', () async {
      final (_, vm) = await crea();
      final p = await conPattuglia(vm);
      await vm.salvaMembri(p, {'a'});
      await pumpEventQueue();
      await vm.rinominaPattuglia(vm.pattuglie.single, 'Logistica');
      await pumpEventQueue();
      expect(vm.pattuglie.single.nome, 'Logistica');
      expect(vm.membriDi(vm.pattuglie.single), [_anna]);
    });

    test('eliminare una pattuglia toglie i suoi compiti dai conteggi', () async {
      final (_, vm) = await crea();
      final p = await conPattuglia(vm);
      await vm.creaCompito(p, 'Menu');
      await pumpEventQueue();
      await vm.eliminaPattuglia(vm.pattuglie.single);
      await pumpEventQueue();
      expect(vm.avanzamento.totali, 0);
    });

    test('un contatto si aggiunge e si toglie', () async {
      final (_, vm) = await crea();
      await vm.creaContatto('Guardia forestale', '333 1234567');
      await pumpEventQueue();
      expect(vm.contatti.single.etichetta, 'Guardia forestale');
      await vm.eliminaContatto(vm.contatti.single);
      await pumpEventQueue();
      expect(vm.contatti, isEmpty);
    });

    test('cambiare il luogo non perde tipo, titolo e date', () async {
      final repo = FakeCampoRepository(campi: [
        Campo(
          id: 'c',
          titolo: 'Estivo',
          tipo: TipoCampo.campoEstivo,
          dataInizio: DateTime(2027, 7, 1),
          dataFine: DateTime(2027, 7, 8),
        ),
      ]);
      final vm = CampoViewModel(repo, 'c');
      await pumpEventQueue();
      await vm.impostaLuogo('Val di Fassa');
      await pumpEventQueue();
      expect(vm.campo!.titolo, 'Estivo');
      expect(vm.campo!.tipo, TipoCampo.campoEstivo);
      expect(vm.campo!.dataFine, DateTime(2027, 7, 8));
      expect(vm.campo!.luogo, 'Val di Fassa');
    });

    test('un campo eliminato nel frattempo non è un errore', () async {
      final vm = CampoViewModel(FakeCampoRepository(), 'sparito');
      await pumpEventQueue();
      expect(vm.haErrore, isFalse);
      expect(vm.campo, isNull);
    });

    test('un errore di lettura diventa uno stato di errore', () async {
      final repo = FakeCampoRepository(campi: [_campo])
        ..erroreLettura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = CampoViewModel(repo, _campo.id);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  test('un testo vuoto non è valido', () {
    expect(erroreTestoCampo('  '), isNotNull);
    expect(erroreTestoCampo('Cucina'), isNull);
  });

  group('CampiView', () {
    Future<void> monta(
      WidgetTester tester, {
      required FakeCampoRepository repo,
      required String branca,
      void Function(BuildContext, Campo)? onApri,
    }) async {
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => CampiViewModel(repo, tipi: TipoCampo.perBranca(branca)),
        child: MaterialApp(home: CampiView(onApri: onApri ?? (_, _) {})),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('chiede quale campo si organizza, secondo la branca', (tester) async {
      await monta(tester, repo: FakeCampoRepository(), branca: 'EG');
      await tester.tap(find.text('Nuovo campo o uscita'));
      await tester.pumpAndSettle();
      expect(find.text('San Giorgio'), findsOneWidget);
      expect(find.text('Route estiva'), findsNothing);
    });

    testWidgets('creato il campo, lo apre', (tester) async {
      final repo = FakeCampoRepository();
      Campo? aperto;
      await monta(tester, repo: repo, branca: 'EG', onApri: (_, c) => aperto = c);

      await tester.tap(find.text('Nuovo campo o uscita'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Campo estivo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CREA'));
      await tester.pumpAndSettle();

      expect(aperto?.tipo, TipoCampo.campoEstivo);
      expect(aperto?.titolo, 'Campo estivo');
      expect(repo.campi, hasLength(1));
    });
  });

  testWidgets('JambRigaContatto mostra chi è e il numero', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: JambRigaContatto(etichetta: 'Guardia forestale', telefono: '333 1234567')),
    ));
    expect(find.text('GUARDIA FORESTALE'), findsOneWidget);
    expect(find.text('333 1234567'), findsOneWidget);
    expect(find.byTooltip('Elimina contatto'), findsNothing);
  });
}
