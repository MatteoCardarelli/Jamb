import 'package:flutter/material.dart';
import 'package:jamb/core/categoria_evento_colori.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';
import '../../../domain/repositories/obiettivo_repository.dart';

/// Stato del form di creazione evento: titolo, luogo, date e categorie;
/// valida i dati e crea l'evento tramite il repository.
class CreaEventoViewModel extends ChangeNotifier {
  final IEventoRepository _eventoRepository;
  final IObiettivoRepository _obiettivoRepository;

  String _titolo = '';
  String _luogo = '';
  DateTime _dataInizio = DateTime.now();
  DateTime _dataFine = DateTime.now().add(const Duration(hours: 1));
  final List<String> _categorieSelezionate = [];
  List<String> _categorieDisponibili = const [categoriaAltro];
  bool _isLoading = true;

  CreaEventoViewModel(this._eventoRepository, this._obiettivoRepository) {
    _caricaCategorie();
  }

  String get titolo => _titolo;
  String get luogo => _luogo;
  DateTime get dataInizio => _dataInizio;
  DateTime get dataFine => _dataFine;
  bool get isLoading => _isLoading;
  List<String> get categorieSelezionate => _categorieSelezionate;

  /// Categorie selezionabili: i domini degli obiettivi del Programma d'Unità,
  /// più la voce "Altro" sempre disponibile.
  List<String> get categorieDisponibili => _categorieDisponibili;

  /// Carica i domini degli obiettivi dell'unità e li usa come categorie.
  Future<void> _caricaCategorie() async {
    _isLoading = true;
    notifyListeners();

    final obiettivi = await _obiettivoRepository.getObiettivi();
    final domini = obiettivi
        .map((o) => o.dominio.trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    _categorieDisponibili = [...domini, categoriaAltro];
    _isLoading = false;
    notifyListeners();
  }

  void setTitolo(String value) {
    _titolo = value;
    notifyListeners();
  }

  void setLuogo(String value) {
    _luogo = value;
    notifyListeners();
  }

  void setDataInizio(DateTime date) {
    _dataInizio = date;
    // Se la data di fine è precedente alla nuova data di inizio, la sposto in avanti
    if (_dataFine.isBefore(_dataInizio)) {
      _dataFine = _dataInizio.add(const Duration(hours: 1));
    }
    notifyListeners();
  }

  void setDataFine(DateTime date) {
    _dataFine = date;
    notifyListeners();
  }

  /// Aggiunge o rimuove una categoria dalla selezione.
  void toggleCategoria(String categoria) {
    if (_categorieSelezionate.contains(categoria)) {
      _categorieSelezionate.remove(categoria);
    } else {
      _categorieSelezionate.add(categoria);
    }
    notifyListeners();
  }

  bool get isValid {
    return _titolo.trim().isNotEmpty &&
        _luogo.trim().isNotEmpty &&
        _categorieSelezionate.isNotEmpty &&
        (_dataFine.isAfter(_dataInizio) || _dataFine.isAtSameMomentAs(_dataInizio));
  }

  Future<void> salvaEvento() async {
    if (!isValid) return;

    final nuovoEvento = Evento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titolo: _titolo.trim(),
      dataInizio: _dataInizio,
      dataFine: _dataFine,
      luogo: _luogo.trim(),
      categorie: List.from(_categorieSelezionate),
      colorePrincipale: coloreCategoria(_categorieSelezionate.first),
    );

    await _eventoRepository.creaEvento(nuovoEvento);
  }
}
