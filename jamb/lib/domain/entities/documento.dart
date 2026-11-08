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

/// Raccolta di documenti navigabile come un albero di cartelle.
enum ArchivioDocumenti {
  /// Drive dell'unità attiva.
  driveBranca('Drive di Branca'),

  /// Drive della Comunità Capi, aperto a tutti i capi del gruppo.
  driveCoca('Drive di Co.Ca.'),

  /// Libreria di gruppo con i documenti ufficiali dell'associazione.
  metodoStatuto('Metodo e Statuto'),

  /// Libreria di gruppo con i moduli e i modelli per le uscite.
  modulistica('Modulistica Uscite');

  final String titolo;
  const ArchivioDocumenti(this.titolo);

  /// `true` per le librerie di gruppo, che modificano solo Capo Unità e
  /// Capo Gruppo; i drive li modificano tutti i capi che li vedono.
  bool get isLibreria => this == metodoStatuto || this == modulistica;
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

  /// Percorso del file nell'archivio; `null` per le cartelle e per i file
  /// senza contenuto (es. inseriti a mano prima dell'archiviazione).
  final String? percorsoFile;

  const Documento({
    required this.id,
    required this.nome,
    required this.tipo,
    this.parentId,
    this.figli,
    required this.ultimaModifica,
    this.dimensioni,
    this.percorsoFile,
  });

  /// Vero se questo nodo è una cartella.
  bool get isCartella => tipo == TipoDocumento.cartella;

  /// Vero se il file ha un contenuto archiviato da aprire.
  bool get apribile => !isCartella && percorsoFile != null;

  /// Restituisce una copia del documento con i campi indicati sostituiti.
  Documento copyWith({
    String? id,
    String? nome,
    TipoDocumento? tipo,
    String? parentId,
    List<Documento>? figli,
    DateTime? ultimaModifica,
    int? dimensioni,
    String? percorsoFile,
  }) {
    return Documento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      parentId: parentId ?? this.parentId,
      figli: figli ?? this.figli,
      ultimaModifica: ultimaModifica ?? this.ultimaModifica,
      dimensioni: dimensioni ?? this.dimensioni,
      percorsoFile: percorsoFile ?? this.percorsoFile,
    );
  }
}

/// Una cartella in cui spostare dei documenti (`id` nullo per la radice),
/// con la profondità a cui mostrarla.
class VoceCartella {
  final String? id;
  final String nome;
  final int livello;

  const VoceCartella({required this.id, required this.nome, required this.livello});
}

/// Albero di [cartelle] in forma di elenco: ogni cartella seguita dalle sue
/// sottocartelle, in ordine alfabetico. Le cartelle in [escluse] non compaiono
/// e con loro il loro contenuto: una cartella non può finire dentro sé stessa.
List<VoceCartella> alberoCartelle(
  Iterable<Documento> cartelle, {
  Set<String> escluse = const {},
}) {
  final perPadre = <String?, List<Documento>>{};
  for (final c in cartelle) {
    perPadre.putIfAbsent(c.parentId, () => []).add(c);
  }
  final elenco = <VoceCartella>[];
  final visitate = <String>{};
  void aggiungi(String? padre, int livello) {
    for (final c in ordinaDocumenti(perPadre[padre] ?? const <Documento>[])) {
      // Un ciclo nei dati non deve bloccare l'app.
      if (escluse.contains(c.id) || !visitate.add(c.id)) continue;
      elenco.add(VoceCartella(id: c.id, nome: c.nome, livello: livello));
      aggiungi(c.id, livello + 1);
    }
  }

  aggiungi(null, 1);
  return elenco;
}

/// Ordine di un elenco di documenti: prima le cartelle, poi i file, ciascuno
/// in ordine alfabetico senza distinguere maiuscole e minuscole.
List<Documento> ordinaDocumenti(Iterable<Documento> documenti) => documenti.toList()
  ..sort((a, b) {
    if (a.isCartella != b.isCartella) return a.isCartella ? -1 : 1;
    return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
  });

/// Tutti i documenti contenuti, a qualunque profondità, nella cartella
/// [idCartella], cercati in [tutti] (i documenti dello stesso archivio).
/// Servono per eliminare dallo storage i file di una cartella cancellata.
List<Documento> discendenti(Iterable<Documento> tutti, String idCartella) {
  final perPadre = <String, List<Documento>>{};
  for (final d in tutti) {
    if (d.parentId != null) perPadre.putIfAbsent(d.parentId!, () => []).add(d);
  }
  final trovati = <Documento>[];
  final daVisitare = [idCartella];
  final visitati = <String>{};
  while (daVisitare.isNotEmpty) {
    final id = daVisitare.removeLast();
    // Un ciclo nei dati non deve bloccare l'app.
    if (!visitati.add(id)) continue;
    for (final figlio in perPadre[id] ?? const <Documento>[]) {
      trovati.add(figlio);
      daVisitare.add(figlio.id);
    }
  }
  return trovati;
}
