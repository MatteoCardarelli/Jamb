/// Tipo di un elemento del drive: una cartella o un formato di file.
enum TipoDocumento {
  pdf, jpeg, png, txt, doc, xls, ppt, zip, cartella;

  /// Converte un nome (proveniente dal DB) nel tipo corrispondente;
  /// per un valore sconosciuto restituisce [TipoDocumento.txt].
  static TipoDocumento safeByName(String? name) {
    if (name == null) return TipoDocumento.txt;
    try {
      return TipoDocumento.values.byName(name);
    } catch (_) {
      return TipoDocumento.txt;
    }
  }

  /// Tipo con cui mostrare un file con estensione [estensione] (minuscola,
  /// senza punto): i formati simili condividono icona e colore.
  static TipoDocumento daEstensione(String estensione) => switch (estensione) {
        'pdf' => TipoDocumento.pdf,
        'jpg' || 'jpeg' || 'webp' || 'heic' => TipoDocumento.jpeg,
        'png' => TipoDocumento.png,
        'doc' || 'docx' || 'odt' => TipoDocumento.doc,
        'xls' || 'xlsx' || 'ods' || 'csv' => TipoDocumento.xls,
        'ppt' || 'pptx' || 'odp' => TipoDocumento.ppt,
        'zip' => TipoDocumento.zip,
        _ => TipoDocumento.txt,
      };
}

/// Lunghezza massima del nome di una cartella o di un file (`documents.titolo`).
const int lunghezzaMassimaNomeDocumento = 150;

/// Motivo per cui [nome] non va bene per una cartella o un file, oppure
/// `null` se va bene.
String? erroreNomeDocumento(String nome) {
  final pulito = nome.trim();
  if (pulito.isEmpty) return 'Il nome non può essere vuoto.';
  if (pulito.length > lunghezzaMassimaNomeDocumento) {
    return 'Il nome è troppo lungo (massimo $lunghezzaMassimaNomeDocumento caratteri).';
  }
  if (pulito.contains('/') || pulito.contains(r'\')) {
    return r'Il nome non può contenere / o \.';
  }
  return null;
}

/// Nodo dell'albero documenti: una cartella o un file.
///
/// L'albero si naviga per [id]/[parentId]; [figli] è opzionale e usato solo
/// per rappresentare una gerarchia già caricata in memoria.
class Documento {
  final String id;
  final String nome;
  final TipoDocumento tipo;
  final String? parentId;
  final List<Documento>? figli;
  final DateTime ultimaModifica;
  final int? dimensioni;

  const Documento({
    required this.id,
    required this.nome,
    required this.tipo,
    this.parentId,
    this.figli,
    required this.ultimaModifica,
    this.dimensioni,
  });

  /// Vero se questo nodo è una cartella.
  bool get isCartella => tipo == TipoDocumento.cartella;

  /// Restituisce una copia del documento con i campi indicati sostituiti.
  Documento copyWith({
    String? id,
    String? nome,
    TipoDocumento? tipo,
    String? parentId,
    List<Documento>? figli,
    DateTime? ultimaModifica,
    int? dimensioni,
  }) {
    return Documento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      parentId: parentId ?? this.parentId,
      figli: figli ?? this.figli,
      ultimaModifica: ultimaModifica ?? this.ultimaModifica,
      dimensioni: dimensioni ?? this.dimensioni,
    );
  }
}
