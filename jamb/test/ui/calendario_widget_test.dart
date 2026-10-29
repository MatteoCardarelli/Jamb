import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/calendario/view_model/calendario_view_model.dart';
import 'package:jamb/ui/calendario/widgets/calendario_widget.dart';
import '../../testing/fakes/fake_evento_repository.dart';

Future<CalendarioViewModel> _monta(WidgetTester tester) async {
  final viewModel = CalendarioViewModel(FakeEventoRepository());
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: viewModel,
    child: const MaterialApp(home: Scaffold(body: CalendarioWidget())),
  ));
  await tester.pump();
  return viewModel;
}

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  group('CalendarioWidget, tasto «Oggi»', () {
    // Il tasto deve restare discreto: compare solo quando serve.
    testWidgets('non compare se si sta già guardando oggi', (tester) async {
      await _monta(tester);
      expect(find.text('Oggi'), findsNothing);
    });

    testWidgets('compare scegliendo un altro giorno e riporta a oggi', (tester) async {
      final viewModel = await _monta(tester);
      final oggi = DateTime.now();

      viewModel.setSelectedDate(oggi.add(const Duration(days: 40)));
      await tester.pump();
      expect(find.text('Oggi'), findsOneWidget);

      await tester.tap(find.text('Oggi'));
      await tester.pump();

      expect(DateUtils.isSameDay(viewModel.selectedDate, oggi), isTrue);
      expect(find.text('Oggi'), findsNothing);
    });
  });
}
