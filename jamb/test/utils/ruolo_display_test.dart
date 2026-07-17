import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/ruolo_display.dart';

void main() {
  group('ruoloLabel', () {
    test('converte un valore enum nell\'etichetta leggibile', () {
      expect(ruoloLabel('VICE_CAPO_SQ'), 'Vice Capo');
      expect(ruoloLabel('CAPO_SQ'), 'Capo Squadriglia');
    });
    test('un valore non mappato resta invariato', () {
      expect(ruoloLabel('SCONOSCIUTO'), 'SCONOSCIUTO');
    });
  });
}