import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/documento.dart';
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

  _testChiediNome();
  _testScegli();
}

/// Apre il dialogo del nome con la validazione dei documenti.
Future<List<String?>> _apriNome(WidgetTester tester) async {
  final risposte = <String?>[];
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          risposte.add(await JambDialogs.chiediNome(
            context,
            titolo: 'Nuova cartella',
            icona: Icons.create_new_folder_rounded,
            conferma: 'CREA',
            valida: erroreNomeDocumento,
          ));
        },
        child: const Text('apri'),
      ),
    ),
  ));
  await tester.tap(find.text('apri'));
  await tester.pumpAndSettle();
  return risposte;
}

void _testChiediNome() {
  group('JambDialogs.chiediNome', () {
    // Un nome rifiutato dal database non deve poter essere confermato.
    testWidgets('con un nome non valido «CREA» è disattivato e spiega perché', (tester) async {
      final risposte = await _apriNome(tester);

      await tester.enterText(find.byType(TextField), 'Uscite/Campo');
      await tester.pump();
      await tester.tap(find.text('CREA'));
      await tester.pumpAndSettle();

      expect(risposte, isEmpty);
      expect(find.textContaining('non può contenere'), findsOneWidget);
    });

    testWidgets('conferma il nome senza spazi intorno', (tester) async {
      final risposte = await _apriNome(tester);

      await tester.enterText(find.byType(TextField), '  Verbali  ');
      await tester.pump();
      await tester.tap(find.text('CREA'));
      await tester.pumpAndSettle();

      expect(risposte, ['Verbali']);
    });
  });
}

/// Apre il dialogo di scelta, tocca [pulsante] e restituisce la scelta.
Future<int?> _scegli(WidgetTester tester, String pulsante) async {
  int? scelta;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          scelta = await JambDialogs.scegli<int>(
            context,
            titolo: 'Elimina evento ripetuto',
            messaggio: 'Questo evento fa parte di una ripetizione.',
            opzioni: const [('Solo questo evento', 1), ('Questo e i successivi', 2)],
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
  return scelta;
}

void _testScegli() {
  // Usato per eliminare eventi ripetuti: annullare non deve scegliere nulla.
  group('JambDialogs.scegli', () {
    testWidgets('Annulla non sceglie nulla', (tester) async {
      expect(await _scegli(tester, 'ANNULLA'), isNull);
    });

    testWidgets('restituisce il valore dell\'opzione toccata', (tester) async {
      expect(await _scegli(tester, 'Questo e i successivi'), 2);
    });
  });
}
