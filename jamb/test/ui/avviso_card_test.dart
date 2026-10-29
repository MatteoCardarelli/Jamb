import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jamb/ui/bacheca/view_model/bacheca_view_model.dart';
import 'package:jamb/ui/bacheca/widgets/avviso_card.dart';
import '../../testing/models/avviso_di_test.dart';

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  Future<void> mostra(WidgetTester tester, {required bool letto}) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AvvisoCard(
          avviso: avvisoDiTest('Ritrovo', squadriglia: 'Aquile', letto: letto),
          onTap: () {},
        ),
      ),
    ));
  }

  group('AvvisoCard', () {
    // Il pallino è l'unico segnale, nell'elenco, di quali avvisi aprire.
    testWidgets('un avviso non letto è segnalato', (tester) async {
      final semantica = tester.ensureSemantics();
      await mostra(tester, letto: false);
      expect(find.bySemanticsLabel(RegExp('Non letto')), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('un avviso letto non ha il segnale', (tester) async {
      final semantica = tester.ensureSemantics();
      await mostra(tester, letto: true);
      expect(find.bySemanticsLabel(RegExp('Non letto')), findsNothing);
      expect(find.textContaining('Aquile'), findsOneWidget);
      semantica.dispose();
    });
  });

  group('BachecaViewModel.dataBreve', () {
    final adesso = DateTime(2026, 10, 29, 18);

    test('di oggi mostra l\'ora', () {
      expect(BachecaViewModel.dataBreve(DateTime(2026, 10, 29, 9, 5), adesso: adesso), '09:05');
    });

    test('di quest\'anno mostra giorno e mese', () {
      expect(BachecaViewModel.dataBreve(DateTime(2026, 3, 7), adesso: adesso), '7 mar');
    });

    test('di un altro anno mostra anche l\'anno', () {
      expect(BachecaViewModel.dataBreve(DateTime(2025, 12, 31), adesso: adesso), '31 dic 2025');
    });
  });
}
