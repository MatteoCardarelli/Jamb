/// Categoria contabile di una transazione di cassa.
enum Categoria {
  materiale,
  attivita,
  trasporto,
  sede,
  quote,
  altro;
}

/// Movimento di cassa (entrata o uscita) di un'unità o gruppo.
class Transazione {
  final String id;
  final String titolo;
  final double importo;
  final bool isUscita;
  final Categoria categoria;
  final DateTime data;
  final String note;
  final String? percorsoRicevuta;
  final String registratoDa;

  const Transazione({
    required this.id,
    required this.titolo,
    required this.importo,
    required this.isUscita,
    required this.categoria,
    required this.data,
    this.note = "",
    this.percorsoRicevuta,
    this.registratoDa = "Utente",
  });

  /// Restituisce una copia della transazione con i campi indicati sostituiti.
  Transazione copyWith({
    String? id,
    String? titolo,
    double? importo,
    bool? isUscita,
    Categoria? categoria,
    DateTime? data,
    String? note,
    String? percorsoRicevuta,
    String? registratoDa,
  }) {
    return Transazione(
      id: id ?? this.id,
      titolo: titolo ?? this.titolo,
      importo: importo ?? this.importo,
      isUscita: isUscita ?? this.isUscita,
      categoria: categoria ?? this.categoria,
      data: data ?? this.data,
      note: note ?? this.note,
      percorsoRicevuta: percorsoRicevuta ?? this.percorsoRicevuta,
      registratoDa: registratoDa ?? this.registratoDa,
    );
  }

  /// Serializza la transazione in una mappa chiave-valore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titolo': titolo,
      'importo': importo,
      'isUscita': isUscita,
      'categoria': categoria.name,
      'data': data.toIso8601String(),
      'note': note,
      'percorsoRicevuta': percorsoRicevuta,
      'registratoDa': registratoDa,
    };
  }

  /// Costruisce una transazione a partire da una mappa serializzata.
  factory Transazione.fromMap(Map<String, dynamic> map) {
    return Transazione(
      id: map['id'],
      titolo: map['titolo'],
      importo: map['importo'],
      isUscita: map['isUscita'],
      categoria: Categoria.values.byName(map['categoria']),
      data: DateTime.parse(map['data']),
      note: map['note'] ?? "",
      percorsoRicevuta: map['percorsoRicevuta'],
      registratoDa: map['registratoDa'] ?? "Utente",
    );
  }
}
