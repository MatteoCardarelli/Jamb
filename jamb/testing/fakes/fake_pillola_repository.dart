import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/pillola.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/pillola_repository.dart';

/// Repository delle pillole finto (in memoria) per i test dei ViewModel.
class FakePillolaRepository extends ChangeNotifier implements IPillolaRepository {
  final List<Pillola> pillole;
  final List<Pillola> spunti;
  JambException? erroreLettura;
  int _prossimoId = 1;

  FakePillolaRepository([List<Pillola>? pillole, List<Pillola>? spunti])
      : pillole = pillole ?? [],
        spunti = spunti ?? [];

  List<Pillola> _di(TipoPillola tipo) => tipo == TipoPillola.metodo ? pillole : spunti;

  @override
  Future<List<Pillola>> getPillole({TipoPillola tipo = TipoPillola.metodo}) async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(_di(tipo));
  }

  @override
  Future<void> crea(String testo, {TipoPillola tipo = TipoPillola.metodo}) async {
    _di(tipo).add(Pillola(id: 'nuova-${_prossimoId++}', testo: testo));
    notifyListeners();
  }

  @override
  Future<void> aggiorna(String id, String testo) async {
    for (final lista in [pillole, spunti]) {
      final i = lista.indexWhere((p) => p.id == id);
      if (i >= 0) lista[i] = Pillola(id: id, testo: testo, comune: lista[i].comune);
    }
    notifyListeners();
  }

  @override
  Future<void> elimina(String id) async {
    pillole.removeWhere((p) => p.id == id);
    spunti.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
