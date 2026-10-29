import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';

/// Apre il dialogo di conferma, tocca [pulsante] e restituisce la risposta.
Future<bool?> _rispondi(WidgetTester tester, String pulsante) async {
  bool? risposta;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          risposta = await JambDialogs.confermaEliminazione(
            context,
            titolo: 'Elimina evento',
            messaggio: 'Vuoi eliminare l\'evento?',
          );
        },
        child: const Text('apri'),
      ),
    ),
  ));
  await tester.tap(find.text('apri'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(pulsante));
  await tester.pumpAndSettle();
  return risposta;
}

void main() {
  // Il dialogo è condiviso da tutte le eliminazioni dell'app: annullare non
  // deve mai confermare.
  group('JambDialogs.confermaEliminazione', () {
    testWidgets('Annulla non conferma', (tester) async {
      expect(await _rispondi(tester, 'ANNULLA'), isFalse);
    });

    testWidgets('Elimina conferma', (tester) async {
      expect(await _rispondi(tester, 'ELIMINA'), isTrue);
    });
  });
}
