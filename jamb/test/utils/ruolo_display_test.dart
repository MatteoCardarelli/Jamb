import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/ruolo_display.dart';

void main() {
  group('ruoloLabel', () {
    // Davanti a un ruolo non mappato la funzione potrebbe sollevare
    // un'eccezione o restituire stringa vuota: restituisce invece il valore
    // grezzo. È una scelta deliberata — se il DB introduce un ruolo che la UI
    // non conosce ancora, la schermata degrada anziché rompersi.
    test('un valore non mappato resta invariato', () {
      expect(ruoloLabel('SCONOSCIUTO'), 'SCONOSCIUTO');
    });
  });
}
