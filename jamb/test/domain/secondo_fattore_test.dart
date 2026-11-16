import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/secondo_fattore.dart';

void main() {
  group('codiceSecondoFattore', () {
    test('accetta 6 cifre, anche incollate con spazi', () {
      expect(codiceSecondoFattore('123456'), '123456');
      expect(codiceSecondoFattore(' 123 456 '), '123456');
    });

    test('rifiuta codici troppo corti, troppo lunghi o con lettere', () {
      expect(codiceSecondoFattore('12345'), isNull);
      expect(codiceSecondoFattore('1234567'), isNull);
      expect(codiceSecondoFattore('12a456'), isNull);
      expect(codiceSecondoFattore(''), isNull);
    });
  });
}
