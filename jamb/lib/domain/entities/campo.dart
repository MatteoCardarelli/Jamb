/// Stato di un compito del campo.
enum StatoCompito {
  daFare('da_fare', 'Da fare'),
  inCorso('in_corso', 'In corso'),
  fatto('fatto', 'Fatto');

  /// Valore della colonna `campo_compiti.stato`.
  final String valoreDb;
  final String etichetta;
  const StatoCompito(this.valoreDb, this.etichetta);

  /// Stato con il valore [valore] del DB; sconosciuto → [daFare].
  static StatoCompito daDb(Object? valore) {
    for (final s in values) {
      if (s.valoreDb == valore) return s;
    }
    return daFare;
  }

  /// Stato successivo nel ciclo, come per i documenti amministrativi.
  StatoCompito get prossimo => values[(index + 1) % values.length];
}

/// Campo dell'unità in un anno scout.
class Campo {
  final String id;
  final String titolo;
  final String luogo;
  final DateTime? dataInizio;
  final DateTime? dataFine;

  const Campo({
    required this.id,
    required this.titolo,
    this.luogo = '',
    this.dataInizio,
    this.dataFine,
  });
}

/// Pattuglia dello Staff.
class Pattuglia {
  final String id;
  final String nome;

  const Pattuglia({required this.id, required this.nome});
}

/// Compito affidato a una pattuglia.
class CompitoCampo {
  final String id;
  final String pattugliaId;
  final String titolo;
  final StatoCompito stato;

  const CompitoCampo({
    required this.id,
    required this.pattugliaId,
    required this.titolo,
    this.stato = StatoCompito.daFare,
  });
}

/// Quanti compiti sono [fatti] su [totali].
class AvanzamentoCampo {
  final int fatti;
  final int totali;

  const AvanzamentoCampo({required this.fatti, required this.totali});

  factory AvanzamentoCampo.di(Iterable<CompitoCampo> compiti) => AvanzamentoCampo(
        fatti: compiti.where((c) => c.stato == StatoCompito.fatto).length,
        totali: compiti.length,
      );

  /// Da 0 a 1; zero se non ci sono compiti.
  double get frazione => totali == 0 ? 0 : fatti / totali;
}
