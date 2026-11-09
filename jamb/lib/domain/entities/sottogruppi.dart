/// Squadriglia o sestiglia di un'unità.
class Squadriglia {
  final String id;
  final String nome;
  final String urlo;

  /// `false` se è stata disattivata: le sue memberships passate restano valide.
  final bool attiva;

  const Squadriglia({
    required this.id,
    required this.nome,
    this.urlo = '',
    this.attiva = true,
  });

  /// Restituisce una copia con i campi indicati sostituiti.
  Squadriglia copyWith({String? nome, String? urlo, bool? attiva}) => Squadriglia(
        id: id,
        nome: nome ?? this.nome,
        urlo: urlo ?? this.urlo,
        attiva: attiva ?? this.attiva,
      );
}

/// Persona con una membership attiva nell'unità: ragazzo o capo.
class MembroUnita {
  final String id;
  final String nome;

  /// Valore di `ruolo_enum`.
  final String ruolo;

  /// Nome della squadriglia (`null` per lo staff).
  final String? squadriglia;

  const MembroUnita({
    required this.id,
    required this.nome,
    required this.ruolo,
    this.squadriglia,
  });
}

/// Sottogruppo con i membri scelti a mano.
enum TipoSottogruppo {
  altaSquadriglia('alta_squadriglia', 'Alta Squadriglia'),
  consiglioRupe('consiglio_rupe', 'Consiglio della Rupe');

  /// Valore della colonna `sottogruppi.tipo`.
  final String valoreDb;
  final String etichetta;
  const TipoSottogruppo(this.valoreDb, this.etichetta);

  /// Tipo con il valore [valore] del DB; `null` se sconosciuto.
  static TipoSottogruppo? daDb(Object? valore) {
    for (final t in values) {
      if (t.valoreDb == valore) return t;
    }
    return null;
  }
}

/// I membri (id degli utenti) di un sottogruppo.
class Sottogruppo {
  final TipoSottogruppo tipo;
  final Set<String> membri;

  const Sottogruppo({required this.tipo, required this.membri});
}

/// Quali sottogruppi ha una branca.
class SottogruppiBranca {
  /// Nome al plurale di squadriglie o sestiglie; `null` se la branca non ne ha.
  final String? gruppi;

  /// Nome al singolare, per i titoli delle azioni.
  final String gruppo;
  final bool consiglioCapi;
  final List<TipoSottogruppo> scelti;

  const SottogruppiBranca({
    this.gruppi,
    this.gruppo = '',
    this.consiglioCapi = false,
    this.scelti = const [],
  });

  /// `true` se la branca non ha alcun sottogruppo da gestire.
  bool get vuota => gruppi == null && !consiglioCapi && scelti.isEmpty;

  /// Configurazione della branca [tipoBranca] (`tipo_branca_enum`), decisa
  /// dall'utente il 2026-11-08; una branca sconosciuta non ha sottogruppi.
  factory SottogruppiBranca.di(String? tipoBranca) => switch (tipoBranca) {
        'EG' => const SottogruppiBranca(
            gruppi: 'Squadriglie',
            gruppo: 'squadriglia',
            consiglioCapi: true,
            scelti: [TipoSottogruppo.altaSquadriglia],
          ),
        'LC' => const SottogruppiBranca(
            gruppi: 'Sestiglie',
            gruppo: 'sestiglia',
            scelti: [TipoSottogruppo.consiglioRupe],
          ),
        _ => const SottogruppiBranca(),
      };
}

/// Lunghezza massima del nome di una squadriglia.
const int lunghezzaMassimaNomeSquadriglia = 50;

/// Forma con cui si confrontano i nomi, come l'indice unico di `squads`.
String _nomeNormalizzato(String nome) => nome.trim().toLowerCase();

/// Motivo per cui [nome] non va bene, oppure `null`. Il nome dev'essere
/// unico tra [esistenti], anche disattivate: ragazzi e bacheca le cercano per
/// nome. [escludiId] è la squadriglia che si sta rinominando.
String? erroreNomeSquadriglia(
  String nome,
  Iterable<Squadriglia> esistenti, {
  String? escludiId,
}) {
  final pulito = nome.trim();
  if (pulito.isEmpty) return 'Il nome non può essere vuoto.';
  if (pulito.length > lunghezzaMassimaNomeSquadriglia) {
    return 'Il nome è troppo lungo (massimo $lunghezzaMassimaNomeSquadriglia caratteri).';
  }
  for (final s in esistenti) {
    if (s.id != escludiId && _nomeNormalizzato(s.nome) == _nomeNormalizzato(pulito)) {
      return s.attiva ? 'Esiste già con questo nome.' : 'Esiste già, disattivata: riattivala.';
    }
  }
  return null;
}

/// Ragazzi che fanno parte di [squadriglia].
List<MembroUnita> membriDi(Squadriglia squadriglia, Iterable<MembroUnita> membri) =>
    membri.where((m) => m.squadriglia == squadriglia.nome).toList();

/// Consiglio Capi, ricavato dalle memberships: i Capi Unità e i Capi
/// Squadriglia delle squadriglie attive, in ordine alfabetico (non gli Aiuto
/// Capo né i vice, indicazione dell'utente del 2026-11-09).
List<MembroUnita> consiglioCapi(
  Iterable<MembroUnita> membri,
  Iterable<Squadriglia> squadriglie,
) {
  final attive = {for (final s in squadriglie) if (s.attiva) s.nome};
  return membri
      .where((m) =>
          m.ruolo == 'CAPO_UNITA' ||
          (m.ruolo == 'CAPO_SQ' && attive.contains(m.squadriglia)))
      .toList()
    ..sort((a, b) => a.nome.compareTo(b.nome));
}
