enum TipoDocumento{
    pdf,
    jpeg,
    png,
    txt,
    doc,
    xls,
    ppt,
    zip,
    cartella;
}

class Documento {
  final String nome;
  final TipoDocumento tipo;
  final List<Documento>? figli; 
  final DateTime ultimaModifica;
  final int? dimensioni;


  const Documento({
    required this.nome,
    required this.tipo,
    this.figli,
    required this.ultimaModifica,
    this.dimensioni,
  });

  bool get isCartella => tipo == TipoDocumento.cartella;

  Documento copyWith({
    String? nome,
    TipoDocumento? tipo,
    List<Documento>? figli,
    DateTime? ultimaModifica,
    int? dimensioni,
  }){
    return Documento(
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      figli: figli ?? this.figli,
      ultimaModifica: ultimaModifica ?? this.ultimaModifica,
      dimensioni: dimensioni ?? this.dimensioni,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo.name,
      'figli': figli?.map((x) => x.toMap()).toList(),
      'ultimaModifica': ultimaModifica.toIso8601String(),
      'dimensioni': dimensioni,
    };
  }

  factory Documento.fromMap(Map<String, dynamic> map) {
    return Documento(
      nome: map['nome'],
      tipo: TipoDocumento.values.byName(map['tipo']),
      figli: map['figli'] != null 
          ? List<Documento>.from((map['figli'] as List).map((x) => Documento.fromMap(x)))
          : null,
      ultimaModifica: DateTime.parse(map['ultimaModifica']),
      dimensioni: map['dimensioni'],
    );
  }
}
