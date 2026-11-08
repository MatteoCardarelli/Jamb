import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// ViewModel dell'Explorer: una cartella di un [archivio] (drive o
/// libreria) con ricerca, percorso e operazioni su cartelle e file.
/// Si ricarica quando il repository cambia.
class ExplorerViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IDocumentoRepository _repository;
  final ArchivioDocumenti archivio;
  final String titolo;
  final String? parentId;
  final List<String> percorsoPrecedente;

  /// Cartelle (`null` = radice) corrispondenti a [percorsoPrecedente].
  final List<String?> idPercorsoPrecedente;

  final TextEditingController searchController = TextEditingController();
  List<Documento> _contenuto = [];
  late List<String> _fullPath;
  final Set<String> _selezionati = {};

  ExplorerViewModel({
    required IDocumentoRepository repository,
    required this.archivio,
    required this.titolo,
    this.parentId,
    this.percorsoPrecedente = const [],
    this.idPercorsoPrecedente = const [],
  }) : _repository = repository {
    _fullPath = [...percorsoPrecedente, titolo];
    searchController.addListener(_onSearchChanged);
    _repository.addListener(_carica);
    _carica();
  }

  List<String> get fullPath => _fullPath;

  /// Cartelle corrispondenti a [fullPath], nello stesso ordine.
  List<String?> get idPercorso => [...idPercorsoPrecedente, parentId];

  /// `true` se è attiva la selezione: un tocco seleziona invece di aprire.
  bool get inSelezione => _selezionati.isNotEmpty;

  int get numeroSelezionati => _selezionati.length;

  bool isSelezionato(Documento d) => _selezionati.contains(d.id);

  /// Documenti selezionati.
  List<Documento> get selezionati =>
      _contenuto.where((d) => _selezionati.contains(d.id)).toList();

  /// Seleziona [d] se non lo è, altrimenti lo toglie.
  void alternaSelezione(Documento d) {
    if (!_selezionati.remove(d.id)) _selezionati.add(d.id);
    notifyListeners();
  }

  /// Aggiunge [d] alla selezione (tocco prolungato, inizio del trascinamento).
  void includiNellaSelezione(Documento d) {
    if (_selezionati.add(d.id)) notifyListeners();
  }

  /// Seleziona tutto ciò che la ricerca mostra.
  void selezionaTutti() {
    _selezionati.addAll(contenutoFiltrato.map((d) => d.id));
    notifyListeners();
  }

  void annullaSelezione() {
    _selezionati.clear();
    notifyListeners();
  }

  /// `true` se la selezione si può rilasciare su [d]: una cartella non scelta.
  bool puoRicevere(Documento d) => d.isCartella && !isSelezionato(d);

  /// Sposta la selezione nella cartella [destinazione] (`null` = radice) e la
  /// chiude; restituisce quanti documenti ha spostato. Un errore viene
  /// propagato alla View e la selezione resta.
  Future<int> spostaSelezione(String? destinazione) async {
    if (destinazione != null && _selezionati.contains(destinazione)) {
      throw const JambException(
        TipoErrore.datiNonValidi,
        'Una cartella non può finire dentro sé stessa.',
      );
    }
    final daSpostare = selezionati.where((d) => d.parentId != destinazione).toList();
    await _repository.sposta(daSpostare, destinazione);
    annullaSelezione();
    return daSpostare.length;
  }

  /// Elimina la selezione, le cartelle con tutto il loro contenuto.
  Future<void> eliminaSelezione() async {
    await _repository.eliminaTutti(archivio, selezionati);
    annullaSelezione();
  }

  /// Cartelle in cui spostare la selezione: la radice e tutte le altre, tranne
  /// quella aperta e le cartelle selezionate con il loro contenuto.
  Future<List<VoceCartella>> destinazioni() async {
    final cartelle = await _repository.getCartelle(archivio);
    return [
      if (parentId != null) VoceCartella(id: null, nome: archivio.titolo, livello: 0),
      ...alberoCartelle(cartelle, escluse: _selezionati).where((c) => c.id != parentId),
    ];
  }

  /// Cartelle e poi file, in ordine alfabetico, filtrati dalla ricerca.
  List<Documento> get contenutoFiltrato {
    final q = searchController.text.toLowerCase().trim();
    return ordinaDocumenti(
      q.isEmpty ? _contenuto : _contenuto.where((d) => d.nome.toLowerCase().contains(q)),
    );
  }

  /// Solo i file del livello corrente, in ordine alfabetico (es. i moduli
  /// proposti alla creazione di un evento).
  List<Documento> get file => contenutoFiltrato.where((d) => !d.isCartella).toList();

  /// Riga sotto il nome: "Cartella", oppure formato e dimensione del file.
  String sottotitolo(Documento d) {
    if (d.isCartella) return 'Cartella';
    if (!d.apribile) return 'Senza contenuto';
    final formato = d.tipo.name.toUpperCase();
    return d.dimensioni == null ? formato : '$formato · ${dimensioneLeggibile(d.dimensioni!)}';
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _contenuto = await _repository.getContenuto(archivio, parentId);
        // Ciò che un altro capo ha tolto nel frattempo non resta selezionato.
        _selezionati.removeWhere((id) => !_contenuto.any((d) => d.id == id));
      });

  /// Ricarica il contenuto della cartella (es. dopo un errore).
  Future<void> refresh() => _carica();

  /// Crea una cartella qui. Un nome non valido o un errore di salvataggio
  /// vengono propagati alla View.
  Future<void> creaCartella(String nome) {
    _verificaNome(nome);
    return _repository.creaCartella(archivio, nome, parentId);
  }

  /// Archivia [file] in questa cartella.
  Future<void> caricaFile(FileDaCaricare file) =>
      _repository.caricaFile(archivio, file, parentId);

  /// Cambia il nome di [documento].
  Future<void> rinomina(Documento documento, String nome) {
    _verificaNome(nome);
    return _repository.rinomina(documento, nome);
  }

  /// Elimina [documento]; una cartella con tutto il suo contenuto.
  Future<void> elimina(Documento documento) => _repository.elimina(archivio, documento);

  /// URL temporaneo per aprire il file [documento].
  Future<String> urlFile(Documento documento) => _repository.urlFile(documento);

  void _verificaNome(String nome) {
    final errore = erroreNomeDocumento(nome);
    if (errore != null) throw JambException(TipoErrore.datiNonValidi, errore);
  }

  void _onSearchChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_carica);
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
