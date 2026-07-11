import 'package:flutter/material.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';

class CreaEventoViewModel extends ChangeNotifier {
  final IEventoRepository _eventoRepository;

  String _titolo = '';
  String _luogo = '';
  DateTime _dataInizio = DateTime.now();
  DateTime _dataFine = DateTime.now().add(const Duration(hours: 1));
  List<CategoriaEvento> _categorieSelezionate = [];

  CreaEventoViewModel(this._eventoRepository);

  String get titolo => _titolo;
  String get luogo => _luogo;
  DateTime get dataInizio => _dataInizio;
  DateTime get dataFine => _dataFine;
  List<CategoriaEvento> get categorieSelezionate => _categorieSelezionate;

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

  void toggleCategoria(CategoriaEvento categoria) {
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

    final colorePrincipale = _categorieSelezionate.first.backgroundColor;

    final nuovoEvento = Evento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titolo: _titolo.trim(),
      dataInizio: _dataInizio,
      dataFine: _dataFine,
      luogo: _luogo.trim(),
      categorie: List.from(_categorieSelezionate),
      colorePrincipale: colorePrincipale == const Color(0xFFE8EAF6) 
          ? const Color(0xFF283593) // Override for better visibility if bg is too light
          : _categorieSelezionate.first.textColor, 
    );

    await _eventoRepository.creaEvento(nuovoEvento);
  }
}
