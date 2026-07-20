import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/scout.dart';

void main() {
  group('DocumentoStatus.safeByName', () {
    test('riconosce un nome valido', () {
      expect(DocumentoStatus.safeByName('valido'), DocumentoStatus.valido);
    });
    test('un nome sconosciuto diventa nessuno', () {
      expect(DocumentoStatus.safeByName('xyz'), DocumentoStatus.nessuno);
    });
  });
}
