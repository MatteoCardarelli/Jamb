import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato della hub Documenti: elenco delle categorie con filtro di ricerca
/// per titolo e ultimi file modificati nel Drive di Branca.
class DocumentiViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IDocumentoRepository _repository;
  final TextEditingController searchController = TextEditingController();
  List<Documento> _recenti = [];

  /// Le categorie che aprono un archivio di documenti hanno la chiave
  /// "archivio"; Amministrazione e Contabilità aprono le loro sezioni.
  final List<Map<String, dynamic>> _allCategories = [
    {"titolo": "Drive di Branca", "sottotitolo": "File condivisi", "icona": Icons.folder_shared_rounded, "archivio": ArchivioDocumenti.driveBranca},
    {"titolo": "Drive di Co.Ca.", "sottotitolo": "File condivisi", "icona": Icons.folder_special_rounded, "archivio": ArchivioDocumenti.driveCoca},
    {"titolo": "Amministrazione", "sottotitolo": "Censimenti e dati", "icona": Icons.admin_panel_settings_rounded},
    {"titolo": "Modulistica Uscite", "sottotitolo": "Template e moduli", "icona": Icons.assignment_rounded, "archivio": ArchivioDocumenti.modulistica},
    {"titolo": "Contabilità", "sottotitolo": "Spese e rimborsi", "icona": Icons.payments_rounded},
    {"titolo": "Metodo e Statuto", "sottotitolo": "Documenti ufficiali", "icona": Icons.menu_book_rounded, "archivio": ArchivioDocumenti.metodoStatuto},
  ];

  DocumentiViewModel(this._repository) {
    searchController.addListener(notifyListeners);
    _repository.addListener(_caricaRecenti);
    _caricaRecenti();
  }

  @override
  void dispose() {
    _repository.removeListener(_caricaRecenti);
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

  Future<void> _caricaRecenti() => eseguiCaricamento(() async {
        _recenti = await _repository.getRecenti();
      });

  /// Ricarica i documenti recenti (es. dopo un errore).
  Future<void> ricaricaRecenti() => _caricaRecenti();

  /// Ultimi file modificati nel Drive di Branca.
  List<Documento> get recenti => _recenti;

  /// Riga sotto il nome di un documento recente, es. "Modificato 7 nov • 2,4 MB".
  String infoRecente(Documento d) => [
        'Modificato ${dataBreve(d.ultimaModifica)}',
        if (d.dimensioni != null) dimensioneLeggibile(d.dimensioni!),
      ].join(' • ');

  /// URL temporaneo per aprire il documento recente [d].
  Future<String> urlFile(Documento d) => _repository.urlFile(d);
}
