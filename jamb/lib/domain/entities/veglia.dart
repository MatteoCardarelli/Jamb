/// Branca a cui è destinata una veglia.
enum BrancaVeglia {
  lc('LC', 'L/C'),
  eg('EG', 'E/G'),
  rs('RS', 'R/S'),
  coca('COCA', 'Co.Ca.');

  /// Valore di `tipo_branca_enum`.
  final String valoreDb;
  final String etichetta;
  const BrancaVeglia(this.valoreDb, this.etichetta);

  /// Branca con il valore [valore] del DB; sconosciuto → [coca].
  static BrancaVeglia daDb(Object? valore) {
    for (final b in values) {
      if (b.valoreDb == valore) return b;
    }
    return coca;
  }
}

/// Tipo di un momento della veglia.
enum TipoMomento {
  canto('Canto'),
  lettura('Lettura'),
  preghiera('Preghiera'),
  riflessione('Riflessione'),
  silenzio('Silenzio');

  final String etichetta;
  const TipoMomento(this.etichetta);

  /// Tipo con il nome [nome]; sconosciuto → [riflessione].
  static TipoMomento daNome(Object? nome) {
    for (final t in values) {
      if (t.name == nome) return t;
    }
    return riflessione;
  }
}

/// Un momento della veglia, nell'ordine in cui si svolge.
class MomentoVeglia {
  final TipoMomento tipo;
  final String testo;

  const MomentoVeglia({required this.tipo, required this.testo});
}

/// Veglia preparata dall'Assistente Ecclesiastico.
class Veglia {
  /// Vuoto per una veglia non ancora salvata.
  final String id;
  final String titolo;
  final BrancaVeglia branca;
  final List<MomentoVeglia> momenti;

  const Veglia({
    this.id = '',
    required this.titolo,
    required this.branca,
    this.momenti = const [],
  });
}
