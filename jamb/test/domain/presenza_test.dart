import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/repositories/supabase_presenza_repository.dart';
import 'package:jamb/domain/entities/presenza.dart';
import '../../testing/models/presenza_di_test.dart';

/// Valori di `stato_presenza_enum` dichiarati nelle migrazioni: quelli della
/// definizione più quelli aggiunti con `ADD VALUE`.
Set<String> _valoriEnumPresenza() {
  final testo = Directory('../supabase/migrations')
      .listSync()
      .whereType<File>()
      .map((f) => f.readAsStringSync())
      .join('\n');
  final definizione = RegExp(
    r'CREATE TYPE "public"\."stato_presenza_enum" AS ENUM \(([^)]*)\)',
  ).firstMatch(testo)!.group(1)!;
  final aggiunti = RegExp(
    r'ALTER TYPE "public"\."stato_presenza_enum" ADD VALUE (?:IF NOT EXISTS )?'
    r"'(\w+)'",
  ).allMatches(testo).map((m) => m.group(1)!);
  return {
    ...RegExp(r"'(\w+)'").allMatches(definizione).map((m) => m.group(1)!),
    ...aggiunti,
  };
}

void main() {
  final adesso = DateTime(2026, 10, 31);

  group('assenzeConsecutive', () {
    test('conta le assenze dalla più recente fino a una presenza', () {
      final storico = [
        presenzaDiTest(1, StatoPresenza.assente),
        presenzaDiTest(5, StatoPresenza.presente),
        presenzaDiTest(10, StatoPresenza.assente),
        presenzaDiTest(20, StatoPresenza.assente),
      ];
      expect(assenzeConsecutive(storico, adesso: adesso), 2);
    });

    test("l'ordine dello storico non conta", () {
      final storico = [
        presenzaDiTest(20, StatoPresenza.presente),
        presenzaDiTest(1, StatoPresenza.assente),
        presenzaDiTest(10, StatoPresenza.assente),
      ];
      expect(assenzeConsecutive(storico, adesso: adesso), 0);
    });

    test('una giustificata non interrompe la serie e non la allunga', () {
      final storico = [
        presenzaDiTest(5, StatoPresenza.assente),
        presenzaDiTest(10, StatoPresenza.giustificato),
        presenzaDiTest(20, StatoPresenza.assente),
      ];
      expect(assenzeConsecutive(storico, adesso: adesso), 2);
    });

    // Un'assenza segnata in anticipo per un evento futuro non è ancora avvenuta.
    test('gli eventi futuri sono ignorati', () {
      final storico = [
        presenzaDiTest(20, StatoPresenza.presente),
        PresenzaRagazzo(
          eventoId: 'futuro',
          titoloEvento: 'Uscita',
          dataEvento: DateTime(2026, 11, 15),
          stato: StatoPresenza.assente,
        ),
      ];
      expect(assenzeConsecutive(storico, adesso: adesso), 0);
    });

    test('senza storico non ci sono assenze', () {
      expect(assenzeConsecutive(const [], adesso: adesso), 0);
    });
  });

  // Un valore che non esiste nell'enum PostgreSQL farebbe fallire ogni
  // salvataggio dell'appello, ma solo a runtime.
  test('ogni stato dell\'appello esiste in stato_presenza_enum', () {
    final valori = _valoriEnumPresenza();
    for (final stato in StatoPresenza.values) {
      expect(valori, contains(SupabasePresenzaRepository.valoreDb(stato)));
    }
  });

  test('gli stati di adesione dal DB non sono esiti d\'appello', () {
    expect(SupabasePresenzaRepository.statoDaDb('INVITATO'), isNull);
    expect(SupabasePresenzaRepository.statoDaDb('CONFERMATO'), isNull);
    expect(SupabasePresenzaRepository.statoDaDb('GIUSTIFICATO'), StatoPresenza.giustificato);
  });
}
