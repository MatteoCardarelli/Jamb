import 'anno_scout.dart';
import 'transazione.dart';

/// Importo in centesimi interi: sommare i `double` accumula errori di
/// arrotondamento, che in un bilancio si vedrebbero.
int centesimiDi(double importo) => (importo * 100).round();

/// Bilancio di una cassa in un anno scout (dal 1° settembre al 31 agosto).
/// Tutti gli importi sono in centesimi.
class Bilancio {
  final String annoScout;

  /// Saldo portato dagli anni precedenti.
  final int saldoIniziale;

  /// Entrate dell'anno per categoria (solo quelle presenti).
  final Map<Categoria, int> entrate;

  /// Uscite dell'anno per categoria (solo quelle presenti).
  final Map<Categoria, int> uscite;

  /// Movimenti dell'anno, dal più vecchio.
  final List<Transazione> movimenti;

  const Bilancio({
    required this.annoScout,
    required this.saldoIniziale,
    required this.entrate,
    required this.uscite,
    required this.movimenti,
  });

  /// Calcola il bilancio di [annoScout] (es. "2025-2026") da tutte le
  /// [transazioni] della cassa: quelle degli anni precedenti formano il saldo
  /// iniziale, quelle degli anni successivi non contano.
  factory Bilancio.daTransazioni(Iterable<Transazione> transazioni, String annoScout) {
    var saldoIniziale = 0;
    final entrate = <Categoria, int>{};
    final uscite = <Categoria, int>{};
    final movimenti = <Transazione>[];

    for (final t in transazioni) {
      final centesimi = centesimiDi(t.importo);
      // Gli anni scout sono "AAAA-AAAA": l'ordine alfabetico è quello cronologico.
      final confronto = annoScoutDi(t.data).compareTo(annoScout);
      if (confronto < 0) {
        saldoIniziale += t.isUscita ? -centesimi : centesimi;
      } else if (confronto == 0) {
        (t.isUscita ? uscite : entrate)
            .update(t.categoria, (v) => v + centesimi, ifAbsent: () => centesimi);
        movimenti.add(t);
      }
    }
    movimenti.sort((a, b) => a.data.compareTo(b.data));

    return Bilancio(
      annoScout: annoScout,
      saldoIniziale: saldoIniziale,
      entrate: entrate,
      uscite: uscite,
      movimenti: movimenti,
    );
  }

  int get totaleEntrate => entrate.values.fold(0, (somma, v) => somma + v);
  int get totaleUscite => uscite.values.fold(0, (somma, v) => somma + v);
  int get saldoFinale => saldoIniziale + totaleEntrate - totaleUscite;
}

/// Anni scout per cui si può vedere un bilancio, dal più recente: quello di
/// [oggi] (anche senza movimenti) e quelli con almeno una delle [transazioni].
List<String> anniDiBilancio(Iterable<Transazione> transazioni, DateTime oggi) {
  final anni = {annoScoutDi(oggi), for (final t in transazioni) annoScoutDi(t.data)};
  return anni.toList()..sort((a, b) => b.compareTo(a));
}

/// Una cassa del gruppo (un'unità o la cassa di gruppo) con tutti i suoi movimenti.
class CassaDelGruppo {
  final String nome;
  final List<Transazione> transazioni;

  const CassaDelGruppo({required this.nome, required this.transazioni});
}

/// Bilancio consolidato del gruppo in un anno scout (US31): il bilancio di
/// ogni cassa e il loro totale.
class BilancioGruppo {
  final List<({String nome, Bilancio bilancio})> casse;
  final Bilancio totale;

  const BilancioGruppo({required this.casse, required this.totale});

  /// Calcola il consolidato di [annoScout] sommando i movimenti di [casse].
  factory BilancioGruppo.daCasse(Iterable<CassaDelGruppo> casse, String annoScout) {
    return BilancioGruppo(
      casse: [
        for (final c in casse)
          (nome: c.nome, bilancio: Bilancio.daTransazioni(c.transazioni, annoScout)),
      ],
      totale: Bilancio.daTransazioni(casse.expand((c) => c.transazioni), annoScout),
    );
  }
}
