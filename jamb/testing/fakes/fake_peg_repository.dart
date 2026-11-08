import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/peg.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/peg_repository.dart';

/// Repository del PEG finto (in memoria) per i test dei ViewModel.
class FakePegRepository extends ChangeNotifier implements IPegRepository {
  Peg peg;
  final List<PegObiettivo> obiettivi;
  final List<GradoCollegato> gradi;
  JambException? erroreLettura;
  int _prossimoId = 1;

  FakePegRepository({this.peg = const Peg(), List<PegObiettivo>? obiettivi, List<GradoCollegato>? gradi})
      : obiettivi = obiettivi ?? [],
        gradi = gradi ?? [];

  @override
  Future<Peg> getPeg() async {
    if (erroreLettura != null) throw erroreLettura!;
    return peg;
  }

  @override
  Future<void> salvaPeg(Peg nuovo) async {
    peg = nuovo;
    notifyListeners();
  }

  @override
  Future<List<PegObiettivo>> getObiettivi() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(obiettivi);
  }

  @override
  Future<void> creaObiettivo(String titolo, String descrizione) async {
    obiettivi.add(PegObiettivo(id: 'nuovo-${_prossimoId++}', titolo: titolo, descrizione: descrizione));
    notifyListeners();
  }

  @override
  Future<void> aggiornaObiettivo(PegObiettivo o) async {
    obiettivi[obiettivi.indexWhere((x) => x.id == o.id)] = o;
    notifyListeners();
  }

  @override
  Future<void> eliminaObiettivo(String id) async {
    obiettivi.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  @override
  Future<List<GradoCollegato>> getGradiCollegati() async => List.of(gradi);
}
