import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/edit_ragazzo_sheet.dart';

/// Pannello per un ragazzo delle Aquile; [onSalva] riceve squadriglia e ruolo.
Widget _pannello({
  required bool puoCambiareRuoloESquadriglia,
  required void Function(String squadriglia, String ruolo) onSalva,
}) {
  return MaterialApp(
    home: Scaffold(
      body: EditRagazzoSheet(
        squadriglia: 'Aquile',
        ruolo: 'RAGAZZO',
        allergie: '',
        privacyScadenza: '',
        contatti: const [],
        squadriglieDisponibili: const ['Aquile', 'Orsi'],
        puoCambiareRuoloESquadriglia: puoCambiareRuoloESquadriglia,
        onSalva: (squadriglia, ruolo, _, _, _) => onSalva(squadriglia, ruolo),
      ),
    ),
  );
}

Future<void> _salva(WidgetTester tester) async {
  await tester.ensureVisible(find.text('SALVA'));
  await tester.tap(find.text('SALVA'));
  await tester.pump();
}

void main() {
  group('EditRagazzoSheet', () {
    // Per un aiuto capo un cambio di squadriglia farebbe fallire l'intero
    // salvataggio (RLS sulle membership): le scelte non devono comparire.
    testWidgets('senza permesso squadriglia e ruolo non sono modificabili', (tester) async {
      (String, String)? salvato;
      await tester.pumpWidget(_pannello(
        puoCambiareRuoloESquadriglia: false,
        onSalva: (squadriglia, ruolo) => salvato = (squadriglia, ruolo),
      ));

      expect(find.text('Solo il Capo Unità può cambiare squadriglia e ruolo.'), findsOneWidget);
      expect(find.text('ORSI'), findsNothing);
      expect(find.text('Vice Capo'), findsNothing);

      await _salva(tester);
      expect(salvato, ('Aquile', 'RAGAZZO'));
    });

    testWidgets('con il permesso squadriglia e ruolo scelti arrivano al salvataggio', (tester) async {
      (String, String)? salvato;
      await tester.pumpWidget(_pannello(
        puoCambiareRuoloESquadriglia: true,
        onSalva: (squadriglia, ruolo) => salvato = (squadriglia, ruolo),
      ));

      await tester.tap(find.text('ORSI'));
      await tester.tap(find.text('Vice Capo'));
      await tester.pump();
      await _salva(tester);

      expect(salvato, ('Orsi', 'VICE_CAPO_SQ'));
    });
  });
}
