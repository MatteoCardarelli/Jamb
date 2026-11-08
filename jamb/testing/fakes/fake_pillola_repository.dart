import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/pillola.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/pillola_repository.dart';

/// Repository delle pillole finto (in memoria) per i test dei ViewModel.
class FakePillolaRepository extends ChangeNotifier implements IPillolaRepository {
  final List<Pillola> pillole;
  JambException? erroreLettura;
  int _prossimoId = 1;

  FakePillolaRepository([List<Pillola>? pillole]) : pillole = pillole ?? [];

  @override
  Future<List<Pillola>> getPillole() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(pillole);
  }

  @override
  Future<void> crea(String testo) async {
    pillole.add(Pillola(id: 'nuova-${_prossimoId++}', testo: testo));
    notifyListeners();
  }

  @override
  Future<void> aggiorna(String id, String testo) async {
    final i = pillole.indexWhere((p) => p.id == id);
    pillole[i] = Pillola(id: id, testo: testo, comune: pillole[i].comune);
    notifyListeners();
  }

  @override
  Future<void> elimina(String id) async {
    pillole.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
