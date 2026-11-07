import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/unita_attiva.dart';

const _reparto = UnitaDisponibile(id: 'eg', nome: 'Reparto Velino', ruolo: 'AIUTO_CAPO');
const _branco = UnitaDisponibile(id: 'lc', nome: 'Branco Seeonee', ruolo: 'CAPO_UNITA');

void main() {
  group('scegliUnitaIniziale', () {
    test("riprende l'unità salvata se è ancora disponibile", () {
      expect(scegliUnitaIniziale([_branco, _reparto], 'eg'), 'eg');
    });

    // Una membership chiusa nel frattempo non deve riaprire un'unità in cui
    // il capo non opera più: si torna alla prima.
    test("ignora un'unità salvata che non è più disponibile", () {
      expect(scegliUnitaIniziale([_branco, _reparto], 'rs'), 'lc');
    });

    test('senza preferenza sceglie la prima', () {
      expect(scegliUnitaIniziale([_branco, _reparto], null), 'lc');
    });

    test('senza unità non ne sceglie nessuna', () {
      expect(scegliUnitaIniziale(const [], 'eg'), isNull);
    });
  });

  group('componiUnitaDisponibili', () {
    test('ordina per nome, così la prima non dipende dal database', () {
      final unita = componiUnitaDisponibili(daMembership: [_reparto, _branco]);
      expect(unita.map((u) => u.id), ['lc', 'eg']);
    });

    test('per il Capo Gruppo aggiunge le unità del gruppo senza doppioni', () {
      final unita = componiUnitaDisponibili(
        daMembership: [_reparto],
        delGruppo: const [
          UnitaDisponibile(id: 'eg', nome: 'Reparto Velino'),
          UnitaDisponibile(id: 'rs', nome: 'Clan Gran Sasso'),
        ],
      );

      expect(unita.map((u) => u.id), ['rs', 'eg']);
      // Il ruolo della membership non va perso a favore della riga senza ruolo.
      expect(unita.firstWhere((u) => u.id == 'eg').ruolo, 'AIUTO_CAPO');
    });
  });
}
