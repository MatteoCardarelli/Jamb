import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/permessi.dart';
import 'package:jamb/domain/entities/formazione.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/profilo/view_model/profilo_view_model.dart';
import 'package:jamb/ui/profilo/widgets/sezioni_formazione.dart';
import '../../testing/fakes/fake_formazione_repository.dart';

TappaCompiuta _t(TappaFormativa t) => TappaCompiuta(tappa: t, data: DateTime(2024, 7, 1));

void main() {
  group('prossimaTappa', () {
    test('senza tappe è il CFT', () {
      expect(prossimaTappa(const []), TappaFormativa.cft);
    });

    test('segue l\'ordine anche se una tappa è stata saltata', () {
      expect(
        prossimaTappa([_t(TappaFormativa.cft), _t(TappaFormativa.cfa)]),
        TappaFormativa.cfm,
      );
    });

    test('con tutte le tappe l\'iter è concluso', () {
      expect(prossimaTappa(TappaFormativa.values.map(_t)), isNull);
    });
  });

  group('ordinaPerIter', () {
    test('mette prima chi è più indietro, a parità per nome', () {
      final capi = ordinaPerIter([
        CapoFormazione(id: '1', nome: 'Zoe', ruolo: 'CAPO_UNITA', tappe: [_t(TappaFormativa.cft)]),
        const CapoFormazione(id: '2', nome: 'Marta', ruolo: 'AIUTO_CAPO'),
        const CapoFormazione(id: '3', nome: 'Luca', ruolo: 'AIUTO_CAPO'),
      ]);
      expect(capi.map((c) => c.nome), ['Luca', 'Marta', 'Zoe']);
    });
  });

  test('un valore sconosciuto del DB non diventa una tappa', () {
    expect(TappaFormativa.daDb('CFZ'), isNull);
  });

  test('le tappe dell\'app coincidono con il vincolo della migrazione', () {
    final migrazione = Directory('../supabase/migrations')
        .listSync()
        .whereType<File>()
        .singleWhere((f) => f.path.endsWith('_formazione_capi.sql'))
        .readAsStringSync();
    for (final t in TappaFormativa.values) {
      expect(migrazione, contains("'${t.valoreDb}'"));
    }
  });

  group('ProfiloViewModel', () {
    Future<(FakeFormazioneRepository, ProfiloViewModel)> crea() async {
      final repo = FakeFormazioneRepository();
      final vm = ProfiloViewModel(repo);
      await pumpEventQueue();
      return (repo, vm);
    }

    test('compiere una tappa e poi correggerne la data non la duplica', () async {
      final (_, vm) = await crea();
      await vm.compiTappa(TappaFormativa.cft, DateTime(2024, 7, 1));
      await pumpEventQueue();
      await vm.compiTappa(TappaFormativa.cft, DateTime(2025, 8, 2));
      await pumpEventQueue();
      expect(vm.tappe.single.data, DateTime(2025, 8, 2));
    });

    test('rimuovere una tappa la riporta da fare', () async {
      final (_, vm) = await crea();
      await vm.compiTappa(TappaFormativa.cft, DateTime(2024, 7, 1));
      await pumpEventQueue();
      await vm.rimuoviTappa(TappaFormativa.cft);
      await pumpEventQueue();
      expect(vm.tappe, isEmpty);
    });

    test('cambiare il testo non perde i passi', () async {
      final (_, vm) = await crea();
      await vm.aggiungiPasso('CFM');
      await pumpEventQueue();
      await vm.salvaTesto('Crescere come capo');
      await pumpEventQueue();
      expect(vm.progetto.testo, 'Crescere come capo');
      expect(vm.progetto.passi.single.titolo, 'CFM');
    });

    test('invertire un passo tocca solo quello e conta i fatti', () async {
      final (_, vm) = await crea();
      await vm.aggiungiPasso('Primo');
      await pumpEventQueue();
      await vm.aggiungiPasso('Secondo');
      await pumpEventQueue();
      await vm.invertiPasso(1);
      await pumpEventQueue();
      expect(vm.progetto.passi.map((p) => p.fatto), [false, true]);
      expect(vm.progetto.passiFatti, 1);
    });

    test('un errore di salvataggio arriva alla View', () async {
      final (repo, vm) = await crea();
      repo.erroreScrittura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      await expectLater(vm.salvaTesto('x'), throwsA(isA<JambException>()));
    });

    test('un errore di lettura diventa uno stato di errore', () async {
      final repo = FakeFormazioneRepository()
        ..erroreLettura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = ProfiloViewModel(repo);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  group('FormazioneCocaViewModel', () {
    test('legge il Progetto del capo scelto', () async {
      final repo = FakeFormazioneRepository()
        ..capi = const [CapoFormazione(id: 'x', nome: 'Marta', ruolo: 'AIUTO_CAPO')]
        ..progettiAltrui['x'] = const ProgettoCapo(testo: 'Il suo progetto');
      final vm = FormazioneCocaViewModel(repo);
      await pumpEventQueue();
      expect((await vm.progettoDi(vm.capi.single)).testo, 'Il suo progetto');
    });
  });

  group('Permessi.puoVedereFormazioneCoca', () {
    test('solo il Capo Gruppo', () {
      expect(const Permessi(ruolo: 'CAPO_UNITA').puoVedereFormazioneCoca, isFalse);
      expect(const Permessi(capoGruppo: true).puoVedereFormazioneCoca, isTrue);
    });
  });

  group('RiquadroProgetto', () {
    // Il Capo Gruppo lo legge soltanto, come vuole la policy.
    testWidgets('senza callback le spunte sono disattivate', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: RiquadroProgetto(
            progetto: ProgettoCapo(passi: [PassoProgetto(titolo: 'CFM')]),
          ),
        ),
      ));
      final spunta = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(spunta.onChanged, isNull);
      expect(find.byTooltip('Elimina passo'), findsNothing);
    });
  });
}
