import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/bilancio.dart';
import 'package:jamb/domain/entities/transazione.dart';
import '../../testing/models/transazione_di_test.dart';

Transazione _entrata(double importo, DateTime data, [Categoria c = Categoria.quote]) =>
    transazioneDiTest('e', importo, false, c, data: data);

Transazione _uscita(double importo, DateTime data, [Categoria c = Categoria.materiale]) =>
    transazioneDiTest('u', importo, true, c, data: data);

void main() {
  group('Bilancio.daTransazioni', () {
    test('il 31 agosto appartiene ancora all\'anno che finisce, anche a tarda sera', () {
      final b = Bilancio.daTransazioni([_entrata(10, DateTime(2026, 8, 31, 23, 59))], '2025-2026');
      expect(b.totaleEntrate, 1000);
      expect(b.saldoIniziale, 0);
    });

    test('il 1° settembre a mezzanotte apre l\'anno nuovo', () {
      final movimenti = [_entrata(10, DateTime(2026, 9, 1))];
      expect(Bilancio.daTransazioni(movimenti, '2025-2026').totaleEntrate, 0);
      expect(Bilancio.daTransazioni(movimenti, '2026-2027').totaleEntrate, 1000);
    });

    test('il saldo iniziale somma tutti gli anni precedenti, uscite in negativo', () {
      final b = Bilancio.daTransazioni([
        _entrata(100, DateTime(2023, 10, 1)),
        _uscita(30, DateTime(2024, 10, 1)),
        _entrata(5, DateTime(2025, 10, 1)),
      ], '2025-2026');
      expect(b.saldoIniziale, 7000);
      expect(b.saldoFinale, 7500);
    });

    test('gli anni successivi non contano', () {
      final b = Bilancio.daTransazioni([_entrata(50, DateTime(2027, 1, 1))], '2025-2026');
      expect(b.saldoIniziale, 0);
      expect(b.saldoFinale, 0);
      expect(b.movimenti, isEmpty);
    });

    test('un anno senza movimenti porta il saldo iniziale fino in fondo', () {
      final b = Bilancio.daTransazioni([_entrata(20, DateTime(2024, 10, 1))], '2025-2026');
      expect(b.movimenti, isEmpty);
      expect(b.saldoFinale, b.saldoIniziale);
      expect(b.saldoFinale, 2000);
    });

    // 0.1 + 0.2 in double fa 0.30000000000000004.
    test('i centesimi si sommano senza errori di arrotondamento', () {
      final data = DateTime(2026, 1, 1);
      final b = Bilancio.daTransazioni(
        [for (var i = 0; i < 1000; i++) _entrata(0.1, data), _entrata(0.2, data)],
        '2025-2026',
      );
      expect(b.totaleEntrate, 10020);
    });

    test('un importo come 19,99 non perde un centesimo', () {
      expect(centesimiDi(19.99), 1999);
      expect(centesimiDi(1.15), 115);
    });

    test('entrate e uscite restano divise per categoria', () {
      final data = DateTime(2026, 1, 1);
      final b = Bilancio.daTransazioni([
        _entrata(10, data, Categoria.quote),
        _entrata(5, data, Categoria.quote),
        _uscita(3, data, Categoria.sede),
        _uscita(4, data, Categoria.quote),
      ], '2025-2026');
      expect(b.entrate, {Categoria.quote: 1500});
      expect(b.uscite, {Categoria.sede: 300, Categoria.quote: 400});
    });

    test('i movimenti sono in ordine di data', () {
      final b = Bilancio.daTransazioni([
        _uscita(1, DateTime(2026, 3, 1)),
        _entrata(1, DateTime(2025, 10, 1)),
      ], '2025-2026');
      expect(b.movimenti.map((t) => t.data.month), [10, 3]);
    });
  });

  group('anniDiBilancio', () {
    test('l\'anno in corso c\'è anche senza movimenti', () {
      expect(anniDiBilancio(const [], DateTime(2026, 11, 8)), ['2026-2027']);
    });

    test('gli anni con movimenti, senza doppioni, dal più recente', () {
      final anni = anniDiBilancio([
        _entrata(1, DateTime(2024, 10, 1)),
        _entrata(1, DateTime(2025, 2, 1)),
        _entrata(1, DateTime(2025, 10, 1)),
      ], DateTime(2026, 11, 8));
      expect(anni, ['2026-2027', '2025-2026', '2024-2025']);
    });
  });
}
