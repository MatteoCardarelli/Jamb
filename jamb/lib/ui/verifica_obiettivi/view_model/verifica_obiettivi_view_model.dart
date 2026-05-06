import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';

/// ViewModel per la gestione dello stato della schermata di verifica obiettivi.
/// Mantiene una lista locale di obiettivi che può essere modificata prima del salvataggio.
class VerificaObiettiviViewModel extends ChangeNotifier {
  final List<Obiettivo> _obiettivi;

  VerificaObiettiviViewModel(List<Obiettivo> initialObiettivi)
      : _obiettivi = List.from(initialObiettivi);

  /// Getter per la lista degli obiettivi correnti
  List<Obiettivo> get obiettivi => _obiettivi;

  /// Aggiorna il punteggio (grado) di un obiettivo specifico
  void updateScore(int index, int newScore) {
    if (index >= 0 && index < _obiettivi.length) {
      _obiettivi[index] = _obiettivi[index].copyWith(grado: newScore);
      notifyListeners();
    }
  }

  /// Aggiorna un obiettivo esistente
  void updateObiettivo(int index, Obiettivo updated) {
    if (index >= 0 && index < _obiettivi.length) {
      _obiettivi[index] = updated;
      notifyListeners();
    }
  }

  /// Aggiunge un nuovo obiettivo alla lista
  void addObiettivo(Obiettivo nuovo) {
    _obiettivi.add(nuovo);
    notifyListeners();
  }

  /// Elimina un obiettivo dalla lista
  void removeObiettivo(int index) {
    if (index >= 0 && index < _obiettivi.length) {
      _obiettivi.removeAt(index);
      notifyListeners();
    }
  }

  /// Restituisce la lista dei colori già in uso dagli obiettivi (escludendo opzionalmente uno specifico ID)
  List<Color> getOccupiedColors({String? excludeId}) {
    return _obiettivi
        .where((o) => o.id != excludeId)
        .map((o) => o.colore)
        .toList();
  }
}
