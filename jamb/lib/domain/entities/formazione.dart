/// Tappe dell'iter formativo di un capo, nell'ordine in cui si percorrono.
enum TappaFormativa {
  cft('CFT', 'Campo di Formazione Tirocinanti'),
  cfm('CFM', 'Campo di Formazione Metodologica'),
  cfa('CFA', 'Campo di Formazione Associativa'),
  nomina('NOMINA', 'Nomina a Capo');

  /// Valore della colonna `iter_formativo.tappa`.
  final String valoreDb;
  final String etichetta;
  const TappaFormativa(this.valoreDb, this.etichetta);

  /// Tappa con il valore [valore] del DB; `null` se sconosciuto.
  static TappaFormativa? daDb(Object? valore) {
    for (final t in values) {
      if (t.valoreDb == valore) return t;
    }
    return null;
  }
}

/// Tappa già compiuta da un capo.
class TappaCompiuta {
  final TappaFormativa tappa;
  final DateTime data;
  final String note;

  const TappaCompiuta({required this.tappa, required this.data, this.note = ''});
}

/// Prima tappa dell'ordine non ancora compiuta; `null` se l'iter è concluso.
TappaFormativa? prossimaTappa(Iterable<TappaCompiuta> compiute) {
  final fatte = {for (final c in compiute) c.tappa};
  for (final t in TappaFormativa.values) {
    if (!fatte.contains(t)) return t;
  }
  return null;
}

/// Passo del Progetto del Capo.
class PassoProgetto {
  final String titolo;
  final bool fatto;

  const PassoProgetto({required this.titolo, this.fatto = false});

  PassoProgetto copyWith({String? titolo, bool? fatto}) =>
      PassoProgetto(titolo: titolo ?? this.titolo, fatto: fatto ?? this.fatto);
}

/// Progetto del Capo: un testo libero e i passi con cui seguirne il percorso.
class ProgettoCapo {
  final String testo;
  final List<PassoProgetto> passi;

  const ProgettoCapo({this.testo = '', this.passi = const []});

  ProgettoCapo copyWith({String? testo, List<PassoProgetto>? passi}) =>
      ProgettoCapo(testo: testo ?? this.testo, passi: passi ?? this.passi);

  int get passiFatti => passi.where((p) => p.fatto).length;
}

/// Un capo del gruppo con il suo iter formativo, visto dal Capo Gruppo.
class CapoFormazione {
  final String id;
  final String nome;

  /// Valore di `ruolo_enum`.
  final String ruolo;
  final List<TappaCompiuta> tappe;

  const CapoFormazione({
    required this.id,
    required this.nome,
    required this.ruolo,
    this.tappe = const [],
  });
}

/// Capi in ordine di iter: prima chi è più indietro, a parità in ordine di
/// nome, così il Capo Gruppo vede subito chi spronare (US29).
List<CapoFormazione> ordinaPerIter(Iterable<CapoFormazione> capi) => capi.toList()
  ..sort((a, b) {
    final diff = a.tappe.length.compareTo(b.tappe.length);
    return diff != 0 ? diff : a.nome.compareTo(b.nome);
  });
