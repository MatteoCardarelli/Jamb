import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jamb/ui/core/formato.dart';

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  // Una data di conseguimento di oggi non deve diventare un orario.
  test('dataInCifre mostra sempre la data completa', () {
    final oggi = DateTime.now();
    expect(dataInCifre(DateTime(2026, 3, 5, 14, 32)), '05/03/2026');
    expect(dataInCifre(oggi), isNot(contains(':')));
  });

  group('dataBreve', () {
    final adesso = DateTime(2026, 10, 29, 18);

    test('di oggi mostra l\'ora', () {
      expect(dataBreve(DateTime(2026, 10, 29, 9, 5), adesso: adesso), '09:05');
    });

    test('di quest\'anno mostra giorno e mese', () {
      expect(dataBreve(DateTime(2026, 3, 7), adesso: adesso), '7 mar');
    });

    test('di un altro anno mostra anche l\'anno', () {
      expect(dataBreve(DateTime(2025, 12, 31), adesso: adesso), '31 dic 2025');
    });
  });

  test('dimensioneLeggibile sceglie l\'unità adatta', () {
    expect(dimensioneLeggibile(800), '800 B');
    expect(dimensioneLeggibile(820 * 1024), '820 KB');
    expect(dimensioneLeggibile((2.4 * 1024 * 1024).round()), '2,4 MB');
  });
}
