import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// ViewModel dell'Explorer: carica cartelle e file reali di un livello
/// dell'albero documenti (per parent_id) e gestisce ricerca + breadcrumbs.
class ExplorerViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IDocumentoRepository _repository;
  final String titolo;
  final String? parentId;
  final List<String> percorsoPrecedente;

  final TextEditingController searchController = TextEditingController();
  List<Documento> _contenuto = [];
  late List<String> _fullPath;

  ExplorerViewModel({
    required IDocumentoRepository repository,
    required this.titolo,
    this.parentId,
    this.percorsoPrecedente = const [],
  }) : _repository = repository {
    _fullPath = [...percorsoPrecedente, titolo];
    searchController.addListener(_onSearchChanged);
    _carica();
  }

  List<String> get fullPath => _fullPath;

  List<Documento> get contenutoFiltrato {
    final q = searchController.text.toLowerCase().trim();
    if (q.isEmpty) return _contenuto;
    return _contenuto.where((d) => d.nome.toLowerCase().contains(q)).toList();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _contenuto = await _repository.getContenuto(parentId);
      });

  /// Ricarica il contenuto della cartella (es. dopo un errore).
  Future<void> refresh() => _carica();

  void _onSearchChanged() => notifyListeners();

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}