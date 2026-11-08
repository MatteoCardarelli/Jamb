import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/permessi.dart';
import 'package:jamb/domain/entities/bilancio.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/contabilita/view_model/bilancio_gruppo_view_model.dart';
import '../../testing/fakes/fake_transazione_repository.dart';
import '../../testing/models/transazione_di_test.dart';

void main() {
  final oggi = DateTime(2026, 11, 8);
  final casse = [
    CassaDelGruppo(nome: 'Branco', transazioni: [
      transazioneDiTest('a', 100, false, Categoria.quote, data: DateTime(2025, 10, 1)),
      transazioneDiTest('b', 40, true, Categoria.sede, data: DateTime(2026, 10, 1)),
    ]),
    CassaDelGruppo(nome: 'Reparto', transazioni: [
      transazioneDiTest('c', 10.25, false, Categoria.quote, data: DateTime(2026, 10, 2)),
    ]),
  ];

  group('BilancioGruppo.daCasse', () {
    test('il totale è la somma delle casse, categoria per categoria', () {
      final b = BilancioGruppo.daCasse(casse, '2026-2027');
      expect(b.totale.saldoIniziale, 10000);
      expect(b.totale.entrate, {Categoria.quote: 1025});
      expect(b.totale.uscite, {Categoria.sede: 4000});
      expect(b.totale.saldoFinale, 7025);
    });

    test('ogni cassa tiene il suo bilancio, nell\'ordine dato', () {
      final b = BilancioGruppo.daCasse(casse, '2026-2027');
      expect(b.casse.map((c) => c.nome), ['Branco', 'Reparto']);
      expect(b.casse[0].bilancio.saldoFinale, 6000);
      expect(b.casse[1].bilancio.saldoFinale, 1025);
    });

    test('una cassa senza movimenti resta in elenco a zero', () {
      final b = BilancioGruppo.daCasse(
          const [CassaDelGruppo(nome: 'Noviziato', transazioni: [])], '2026-2027');
      expect(b.casse.single.bilancio.saldoFinale, 0);
    });
  });

  group('BilancioGruppoViewModel', () {
    test('propone gli anni con movimenti in qualunque cassa', () async {
      final vm = BilancioGruppoViewModel(FakeTransazioneRepository(const [], casse: casse), oggi: oggi);
      await pumpEventQueue();
      expect(vm.anni, ['2026-2027', '2025-2026']);
    });

    test('cambiando anno cambia il consolidato', () async {
      final vm = BilancioGruppoViewModel(FakeTransazioneRepository(const [], casse: casse), oggi: oggi);
      await pumpEventQueue();
      vm.scegliAnno('2025-2026');
      expect(vm.consolidato.totale.saldoIniziale, 0);
      expect(vm.consolidato.totale.totaleEntrate, 10000);
    });

    test('un errore di lettura non mostra totali falsi', () async {
      final vm = BilancioGruppoViewModel(
        FakeTransazioneRepository(const [],
            erroreLettura: const JambException(TipoErrore.rete, 'Nessuna connessione')),
        oggi: oggi,
      );
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  group('Permessi.puoVedereBilancioGruppo', () {
    test('solo il Capo Gruppo, non il Capo Unità', () {
      expect(const Permessi(ruolo: 'CAPO_UNITA').puoVedereBilancioGruppo, isFalse);
      expect(const Permessi(ruolo: 'CAPO_UNITA', capoGruppo: true).puoVedereBilancioGruppo, isTrue);
    });
  });
}
