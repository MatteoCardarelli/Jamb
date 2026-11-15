import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/obiettivo.dart';

void main() {
  test(
    "ogni icona del dialogo si ricostruisce dal codice salvato nel database",
    () {
      for (final icona in iconeObiettivo) {
        expect(iconaObiettivoDaCodice(icona.codePoint), icona);
      }
    },
  );

  test("l'icona predefinita di un obiettivo nuovo si ricostruisce", () {
    expect(
      iconaObiettivoDaCodice(iconaObiettivoPredefinita.codePoint),
      iconaObiettivoPredefinita,
    );
  });

  test("un codice assente o sconosciuto degrada all'icona predefinita", () {
    expect(iconaObiettivoDaCodice(null), iconaObiettivoPredefinita);
    expect(iconaObiettivoDaCodice(1), iconaObiettivoPredefinita);
  });
}
