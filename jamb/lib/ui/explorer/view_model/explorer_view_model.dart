import 'package:flutter/material.dart';

/// ViewModel per la gestione dello stato dell'Explorer.
/// Gestisce la ricerca e la navigazione nel percorso dei documenti.
class ExplorerViewModel extends ChangeNotifier {
  final String titolo;
  final List<String> cartelle;
  final List<String> percorsoPrecedente;
  
  final TextEditingController searchController = TextEditingController();
  List<String> _filteredCartelle = [];
  late List<String> _fullPath;

  ExplorerViewModel({
    required this.titolo,
    required this.cartelle,
    this.percorsoPrecedente = const [],
  }) {
    _filteredCartelle = cartelle;
    _fullPath = [...percorsoPrecedente, titolo];
    searchController.addListener(_onSearchChanged);
  }

  /// Getter per la lista delle cartelle filtrate in base alla ricerca
  List<String> get filteredCartelle => _filteredCartelle;

  /// Getter per il percorso completo (Breadcrumbs)
  List<String> get fullPath => _fullPath;

  /// Filtra le cartelle quando cambia il testo nella barra di ricerca
  void _onSearchChanged() {
    _filteredCartelle = cartelle
        .where((c) => c.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
