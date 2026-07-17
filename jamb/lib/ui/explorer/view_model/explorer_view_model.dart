import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';

/// ViewModel dell'Explorer: carica cartelle e file reali di un livello
/// dell'albero documenti (per parent_id) e gestisce ricerca + breadcrumbs.
class ExplorerViewModel extends ChangeNotifier {
  final IDocumentoRepository _repository;
  final String titolo;
  final String? parentId;
  final List<String> percorsoPrecedente;

  final TextEditingController searchController = TextEditingController();
  List<Documento> _contenuto = [];
  bool _isLoading = true;
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

  bool get isLoading => _isLoading;
  List<String> get fullPath => _fullPath;

  List<Documento> get contenutoFiltrato {
    final q = searchController.text.toLowerCase().trim();
    if (q.isEmpty) return _contenuto;
    return _contenuto.where((d) => d.nome.toLowerCase().contains(q)).toList();
  }

  Future<void> _carica() async {
    _isLoading = true;
    notifyListeners();
    _contenuto = await _repository.getContenuto(parentId);
    _isLoading = false;
    notifyListeners();
  }

  void _onSearchChanged() => notifyListeners();

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}