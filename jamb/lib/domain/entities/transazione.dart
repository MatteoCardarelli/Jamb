enum Categoria{ 
    materiale,
    attivita,
    trasporto,
    sede,
    altro;
}

class Transazione{
    final String id;
    final String titolo;
    final double importo;
    final bool isUscita;
    final Categoria categoria;
    final DateTime data;
    final String note;
    final String? percorsoRicevuta;
    
    const Transazione({
        required this.id,
        required this.titolo,
        required this.importo,
        required this.isUscita,
        required this.categoria,
        required this.data,
        this.note = "",
        this.percorsoRicevuta,
    });

    Transazione copyWith({
        String? id,
        String? titolo,
        double? importo,
        bool? isUscita,
        Categoria? categoria,
        DateTime? data,
        String? note,
        String? percorsoRicevuta,
    }){
        return Transazione(
            id: id ?? this.id,
            titolo: titolo ?? this.titolo,
            importo: importo ?? this.importo,
            isUscita: isUscita ?? this.isUscita,
            categoria: categoria ?? this.categoria,
            data: data ?? this.data,
            note: note ?? this.note,
            percorsoRicevuta: percorsoRicevuta ?? this.percorsoRicevuta,
        );
    }

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
        };
    }

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
        );
    }
}   