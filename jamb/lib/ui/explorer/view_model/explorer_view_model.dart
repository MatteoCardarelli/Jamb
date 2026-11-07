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

  final TextEditingController searchController = TextEditingController();
  List<Documento> _contenuto = [];
  late List<String> _fullPath;

  ExplorerViewModel({
    required IDocumentoRepository repository,
    required this.archivio,
    required this.titolo,
    this.parentId,
    this.percorsoPrecedente = const [],
  }) : _repository = repository {
    _fullPath = [...percorsoPrecedente, titolo];
    searchController.addListener(_onSearchChanged);
    _repository.addListener(_carica);
    _carica();
  }

  List<String> get fullPath => _fullPath;

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
