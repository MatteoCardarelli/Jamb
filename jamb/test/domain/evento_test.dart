import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/anno_scout.dart';
import 'package:jamb/domain/entities/evento.dart';
import '../../testing/models/evento_di_test.dart';

void main() {
  final riunione = eventoDiTest(
    'riunione',
    DateTime(2026, 11, 7, 15, 30),
    fine: DateTime(2026, 11, 7, 17, 30),
  );

  group('eventiDellaSerie', () {
    test('senza ripetizione restituisce il solo evento', () {
      expect(eventiDellaSerie(riunione, Ripetizione.mai, DateTime(2027, 1, 1)), [riunione]);
    });

    test('ogni settimana fino alla data inclusa, con stessa ora e durata', () {
      final serie = eventiDellaSerie(riunione, Ripetizione.ogniSettimana, DateTime(2026, 11, 28));
      expect(serie.map((e) => e.dataInizio.day), [7, 14, 21, 28]);
      expect(serie.last.dataInizio, DateTime(2026, 11, 28, 15, 30));
      expect(serie.last.dataFine, DateTime(2026, 11, 28, 17, 30));
      expect(serie.every((e) => e.ripetizione == Ripetizione.ogniSettimana), isTrue);
    });

    // Un mese senza il 31 non deve far saltare la riunione né spostare le
    // successive: si usa l'ultimo giorno del mese e poi si torna al 31.
    test('ogni mese da un 31 usa l\'ultimo giorno dei mesi più corti', () {
      final fineMese = eventoDiTest('cassa', DateTime(2027, 1, 31, 21));
      final serie = eventiDellaSerie(fineMese, Ripetizione.ogniMese, DateTime(2027, 4, 30));
      expect(serie.map((e) => e.dataInizio), [
        DateTime(2027, 1, 31, 21),
        DateTime(2027, 2, 28, 21),
        DateTime(2027, 3, 31, 21),
        DateTime(2027, 4, 30, 21),
      ]);
    });

    test('ogni anno dal 29 febbraio cade il 28 negli anni non bisestili', () {
      final bisestile = eventoDiTest('festa', DateTime(2028, 2, 29, 10));
      final serie = eventiDellaSerie(bisestile, Ripetizione.ogniAnno, DateTime(2032, 12, 31));
      expect(serie.map((e) => e.dataInizio.day), [29, 28, 28, 28, 29]);
    });

    // Un campo di tre giorni resta di tre giorni in ogni ripetizione.
    test('un evento di più giorni mantiene la durata', () {
      final campo = eventoDiTest('campo', DateTime(2026, 12, 27, 9), fine: DateTime(2026, 12, 29, 18));
      final serie = eventiDellaSerie(campo, Ripetizione.ogniAnno, DateTime(2027, 12, 31));
      expect(serie.last.dataFine, DateTime(2027, 12, 29, 18));
    });

    test('non supera il massimo anche con una data di fine lontana', () {
      final serie = eventiDellaSerie(riunione, Ripetizione.ogniGiorno, DateTime(2030, 1, 1));
      expect(serie, hasLength(massimoRipetizioni));
    });

    test('una data di fine precedente all\'inizio non crea eventi', () {
      expect(eventiDellaSerie(riunione, Ripetizione.ogniGiorno, DateTime(2026, 11, 6)), isEmpty);
    });
  });

  test('una modifica alla serie cambia orari e dati ma non il giorno', () {
    final successiva = eventoDiTest('successiva', DateTime(2026, 11, 14, 15, 30))
        .copyWith(serieId: 'serie', ripetizione: Ripetizione.ogniSettimana);
    final modificato = riunione.copyWith(
      titolo: 'Riunione di reparto',
      luogo: 'Bosco',
      dataInizio: DateTime(2026, 11, 7, 16),
      dataFine: DateTime(2026, 11, 7, 18, 30),
    );

    final risultato = applicaAllaSerie(modificato, successiva);

    expect(risultato.id, 'successiva');
    expect(risultato.serieId, 'serie');
    expect(risultato.titolo, 'Riunione di reparto');
    expect(risultato.luogo, 'Bosco');
    expect(risultato.dataInizio, DateTime(2026, 11, 14, 16));
    expect(risultato.dataFine, DateTime(2026, 11, 14, 18, 30));
  });

  test('la fine proposta per una ripetizione è il 31 agosto dell\'anno scout', () {
    expect(fineAnnoScout(DateTime(2026, 11, 7)), DateTime(2027, 8, 31));
    expect(fineAnnoScout(DateTime(2027, 3, 1)), DateTime(2027, 8, 31));
  });
}
