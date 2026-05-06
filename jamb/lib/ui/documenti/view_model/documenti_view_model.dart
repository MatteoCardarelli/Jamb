import 'package:flutter/material.dart';

class DocumentiViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  // Dati statici/mock. In futuro potranno venire da un API/Repository
  final List<Map<String, dynamic>> _allCategories = [
    {"titolo": "Drive di Branca", "sottotitolo": "File condivisi", "icona": Icons.folder_shared_rounded},
    {"titolo": "Drive di Co.Ca.", "sottotitolo": "File condivisi", "icona": Icons.folder_special_rounded},
    {"titolo": "Amministrazione", "sottotitolo": "Censimenti e dati", "icona": Icons.admin_panel_settings_rounded},
    {"titolo": "Modulistica Uscite", "sottotitolo": "Template e moduli", "icona": Icons.assignment_rounded},
    {"titolo": "Contabilità", "sottotitolo": "Spese e rimborsi", "icona": Icons.payments_rounded},
    {"titolo": "Metodo e Statuto", "sottotitolo": "Documenti ufficiali", "icona": Icons.menu_book_rounded},
  ];

  DocumentiViewModel() {
    searchController.addListener(() {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get categorieFiltrate {
    final query = searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _allCategories;
    
    return _allCategories
        .where((c) => c['titolo'].toString().toLowerCase().contains(query))
        .toList();
  }
}
