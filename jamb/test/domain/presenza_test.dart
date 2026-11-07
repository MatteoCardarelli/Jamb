import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/repositories/supabase_presenza_repository.dart';
import 'package:jamb/domain/entities/presenza.dart';
import '../../testing/models/evento_di_test.dart';
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

  group('eventoPerAppello', () {
    final ora = DateTime(2026, 11, 7, 15, 30);
    DateTime alle(int giorno, int h, [int m = 0]) => DateTime(2026, 11, giorno, h, m);

    test("l'evento in corso vince su quelli recenti e imminenti", () {
      final eventi = [
        eventoDiTest('ieri', alle(6, 15)),
        eventoDiTest('riunione', alle(7, 15), fine: alle(7, 17)),
        eventoDiTest('tra poco', alle(7, 16)),
      ];
      expect(eventoPerAppello(eventi, ora)?.id, 'riunione');
    });

    test('tra due eventi in corso sceglie quello iniziato più di recente', () {
      final eventi = [
        eventoDiTest('campo', alle(5, 9), fine: alle(9, 18)),
        eventoDiTest('veglia', alle(7, 15), fine: alle(7, 18)),
      ];
      expect(eventoPerAppello(eventi, ora)?.id, 'veglia');
    });

    // L'appello si fa spesso all'arrivo, qualche minuto prima dell'inizio.
    test("senza eventi in corso sceglie quello che inizia entro un'ora", () {
      final eventi = [
        eventoDiTest('ieri', alle(6, 15)),
        eventoDiTest('riunione', alle(7, 16)),
      ];
      expect(eventoPerAppello(eventi, ora)?.id, 'riunione');
    });

    test("altrimenti l'ultimo iniziato nell'ultima settimana", () {
      final eventi = [
        eventoDiTest('martedì', alle(3, 15)),
        eventoDiTest('giovedì', alle(5, 15)),
        eventoDiTest('domani', alle(8, 15)),
      ];
      expect(eventoPerAppello(eventi, ora)?.id, 'giovedì');
    });

    test('eventi troppo lontani nel passato o nel futuro non contano', () {
      final eventi = [
        eventoDiTest('due settimane fa', alle(7, 15).subtract(const Duration(days: 14))),
        eventoDiTest('stasera', alle(7, 21)),
      ];
      expect(eventoPerAppello(eventi, ora), isNull);
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
