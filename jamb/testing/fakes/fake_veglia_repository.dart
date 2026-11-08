import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/veglia.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/veglia_repository.dart';

/// Repository delle veglie finto (in memoria) per i test dei ViewModel.
class FakeVegliaRepository extends ChangeNotifier implements IVegliaRepository {
  final List<Veglia> veglie;
  JambException? erroreLettura;
  JambException? erroreScrittura;
  int _prossimoId = 1;

  FakeVegliaRepository([List<Veglia>? veglie]) : veglie = veglie ?? [];

  @override
  Future<List<Veglia>> getVeglie() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(veglie);
  }

  @override
  Future<void> salva(Veglia v) async {
    if (erroreScrittura != null) throw erroreScrittura!;
    if (v.id.isEmpty) {
      veglie.add(Veglia(id: 'nuova-${_prossimoId++}', titolo: v.titolo, branca: v.branca, momenti: v.momenti));
    } else {
      veglie[veglie.indexWhere((x) => x.id == v.id)] = v;
    }
    notifyListeners();
  }

  @override
  Future<void> elimina(String id) async {
    veglie.removeWhere((v) => v.id == id);
    notifyListeners();
  }
}
