import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/formazione.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/formazione_repository.dart';

/// Repository della formazione finto (in memoria) per i test dei ViewModel.
class FakeFormazioneRepository extends ChangeNotifier implements IFormazioneRepository {
  final Map<TappaFormativa, TappaCompiuta> tappe = {};
  ProgettoCapo progetto = const ProgettoCapo();
  List<CapoFormazione> capi = const [];
  final Map<String, ProgettoCapo> progettiAltrui = {};
  JambException? erroreLettura;
  JambException? erroreScrittura;

  void _controllaScrittura() {
    if (erroreScrittura != null) throw erroreScrittura!;
  }

  @override
  Future<List<TappaCompiuta>> getMieTappe() async {
    if (erroreLettura != null) throw erroreLettura!;
    return tappe.values.toList();
  }

  @override
  Future<void> salvaTappa(TappaCompiuta tappa) async {
    _controllaScrittura();
    tappe[tappa.tappa] = tappa;
    notifyListeners();
  }

  @override
  Future<void> rimuoviTappa(TappaFormativa tappa) async {
    _controllaScrittura();
    tappe.remove(tappa);
    notifyListeners();
  }

  @override
  Future<ProgettoCapo> getMioProgetto() async => progetto;

  @override
  Future<void> salvaMioProgetto(ProgettoCapo p) async {
    _controllaScrittura();
    progetto = p;
    notifyListeners();
  }

  @override
  Future<List<CapoFormazione>> getCapiDelGruppo() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(capi);
  }

  @override
  Future<ProgettoCapo> getProgettoDi(String userId) async =>
      progettiAltrui[userId] ?? const ProgettoCapo();
}
