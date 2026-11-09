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

/// Tipo di campo o di uscita, tra i momenti forti dell'anno di ogni branca.
enum TipoCampo {
  campoInvernale('campo_invernale', 'Campo invernale'),
  sanGiorgio('san_giorgio', 'San Giorgio'),
  campoEstivo('campo_estivo', 'Campo estivo'),
  vacanzeBranco('vacanze_branco', 'Vacanze di Branco'),
  routeEstiva('route_estiva', 'Route estiva'),
  routeInvernale('route_invernale', 'Route invernale'),
  uscita('uscita', 'Uscita');

  /// Valore della colonna `campi.tipo`.
  final String valoreDb;
  final String etichetta;
  const TipoCampo(this.valoreDb, this.etichetta);

  /// Tipo con il valore [valore] del DB; sconosciuto → [uscita].
  static TipoCampo daDb(Object? valore) {
    for (final t in values) {
      if (t.valoreDb == valore) return t;
    }
    return uscita;
  }

  /// Tipi proposti alla branca [tipoBranca] (`tipo_branca_enum`); per una
  /// branca sconosciuta resta l'uscita generica.
  static List<TipoCampo> perBranca(String? tipoBranca) => switch (tipoBranca) {
        'EG' => const [campoInvernale, sanGiorgio, campoEstivo, uscita],
        'LC' => const [vacanzeBranco, uscita],
        'RS' => const [routeEstiva, routeInvernale, uscita],
        _ => const [uscita],
      };
}

/// Campo o uscita dell'unità.
class Campo {
  final String id;
  final TipoCampo tipo;
  final String annoScout;
  final String titolo;
  final String luogo;
  final DateTime? dataInizio;
  final DateTime? dataFine;

  const Campo({
    required this.id,
    required this.titolo,
    this.tipo = TipoCampo.uscita,
    this.annoScout = '',
    this.luogo = '',
    this.dataInizio,
    this.dataFine,
  });
}

/// Pattuglia dello Staff, con i capi che ne fanno parte.
class Pattuglia {
  final String id;
  final String nome;

  /// Id degli utenti che compongono la pattuglia.
  final Set<String> membri;

  const Pattuglia({required this.id, required this.nome, this.membri = const {}});
}

/// Numero di telefono utile per un campo, con chi è e a cosa serve.
class ContattoCampo {
  final String id;
  final String etichetta;
  final String telefono;

  const ContattoCampo({required this.id, required this.etichetta, required this.telefono});
}

/// Motivo per cui [telefono] non va bene, oppure `null`: solo cifre, con
/// spazi e un eventuale prefisso internazionale.
String? erroreTelefono(String telefono) {
  final pulito = telefono.replaceAll(RegExp(r'[\s./-]'), '');
  if (pulito.isEmpty) return 'Il numero non può essere vuoto.';
  if (!RegExp(r'^\+?\d{3,15}$').hasMatch(pulito)) return 'Il numero non è valido.';
  return null;
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
