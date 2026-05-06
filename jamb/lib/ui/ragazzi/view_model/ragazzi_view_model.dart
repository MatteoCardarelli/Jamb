import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';

/// ViewModel per la gestione della lista dei ragazzi.
/// Utilizza l'entità di dominio [Scout] come unica fonte di verità e carica i dati dal Repository.
class RagazziViewModel extends ChangeNotifier {
  final IScoutRepository _repository;
  final TextEditingController searchController = TextEditingController();

  List<Scout> _tuttiRagazzi = [];
  bool _isLoading = true;
  String? _squadrigliaFiltro;
  bool _alertFiltro = false;

  RagazziViewModel(this._repository) {
    searchController.addListener(() {
      notifyListeners();
    });
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    _isLoading = true;
    notifyListeners();
    
    _tuttiRagazzi = await _repository.getRagazzi();
    
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => searchController.text;
  String? get squadrigliaFiltro => _squadrigliaFiltro;
  bool get alertFiltro => _alertFiltro;

  /// Estrae la lista unica di squadriglie dai dati
  List<String> get squadriglie {
    final set = _tuttiRagazzi.map((r) => r.squadriglia).toSet().toList()..sort();
    return set;
  }

  /// Applica i filtri (testo, squadriglia, alert) alla lista dei ragazzi
  List<Scout> get ragazziFiltrati {
    final query = searchQuery.toLowerCase().trim();
    return _tuttiRagazzi.where((r) {
      final matchText = query.isEmpty ||
          r.nome.toLowerCase().contains(query) ||
          r.squadriglia.toLowerCase().contains(query);

      final matchSquadriglia = _squadrigliaFiltro == null ||
          r.squadriglia.toLowerCase() == _squadrigliaFiltro!.toLowerCase();

      final hasAlert = r.allergie != null && r.allergie!.trim().isNotEmpty;

      final matchAlert = !_alertFiltro || hasAlert;

      return matchText && matchSquadriglia && matchAlert;
    }).toList();
  }

  // Azioni
  void setSquadrigliaFiltro(String? sq) {
    _squadrigliaFiltro = sq;
    notifyListeners();
  }

  void setAlertFiltro(bool alert) {
    _alertFiltro = alert;
    notifyListeners();
  }

  /// Forza il ricaricamento dei dati dal repository
  Future<void> refresh() async {
    await _caricaDati();
  }
}
