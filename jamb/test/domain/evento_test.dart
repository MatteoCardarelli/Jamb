import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/categoria_evento_colori.dart';

void main() {
  group('coloreCategoria', () {
    // "Altro" è l'unica categoria con un colore riservato: le altre sono i
    // titoli degli obiettivi dell'unità e ricevono un colore derivato dal nome.
    // Il riconoscimento deve reggere le maiuscole, perché la stringa arriva sia
    // dalla costante sia da righe salvate a DB.
    test('"Altro" è riconosciuto a prescindere dalle maiuscole', () {
      expect(coloreCategoria('altro'), coloreCategoria(categoriaAltro));
      expect(coloreCategoria('ALTRO'), coloreCategoria(categoriaAltro));
    });
  });
}
