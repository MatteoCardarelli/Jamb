import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/domain/repositories/obiettivo_repository.dart';

/// Stato della Home: conta i ragazzi, calcola gli avvisi amministrativi e
/// gestisce il salvataggio degli obiettivi. Si ricarica al variare degli scout.
class HomeViewModel extends ChangeNotifier {
  final IScoutRepository _scoutRepository;
  final IObiettivoRepository _obiettivoRepository;

  List<Scout> _ragazzi = [];
  List<Obiettivo> _obiettivi = [];
  bool _isLoading = true;

  HomeViewModel(this._scoutRepository, this._obiettivoRepository) {
    // Si mette in ascolto del repository: se i dati cambiano (es. in Amministrazione),
    // la Home si ricarica automaticamente.
    _scoutRepository.addListener(_caricaDati);
    _caricaDati();
  }

  @override
  void dispose() {
    _scoutRepository.removeListener(_caricaDati);
    super.dispose();
  }

  Future<void> _caricaDati() async {
    _isLoading = true;
    notifyListeners();

    _ragazzi = await _scoutRepository.getRagazzi();
    _obiettivi = await _obiettivoRepository.getObiettivi();

    _isLoading = false;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  List<Obiettivo> get obiettivi => _obiettivi;
  int get numeroRagazzi => _ragazzi.length;

  /// Restituisce il messaggio di alert solo se ci sono criticità amministrative reali.
  String get alertMessage {
    int scaduti = _ragazzi.where((r) => 
      r.statoCensimento == DocumentoStatus.scaduto || 
      r.statoPrivacy == DocumentoStatus.scaduto || 
      r.statoMedica == DocumentoStatus.scaduto
    ).length;

    int inScadenza = _ragazzi.where((r) => 
      r.statoCensimento == DocumentoStatus.inScadenza || 
      r.statoPrivacy == DocumentoStatus.inScadenza || 
      r.statoMedica == DocumentoStatus.inScadenza
    ).length;

    if (scaduti == 0 && inScadenza == 0) return "";

    List<String> parti = [];
    if (scaduti > 0) parti.add("$scaduti documenti scaduti");
    if (inScadenza > 0) parti.add("$inScadenza in scadenza");

    return "${parti.join(" e ")} richiedono attenzione.";
  }

  /// Salva la lista di obiettivi: elimina quelli rimossi, aggiorna/crea i
  /// restanti e ricarica per allineare gli id generati dal DB.
  Future<void> updateObiettivi(List<Obiettivo> updatedList) async {
    // Elimina dal DB gli obiettivi rimossi dalla lista (diff vecchi/nuovi id).
    final vecchiIds = _obiettivi.map((o) => o.id).toSet();
    final nuoviIds = updatedList.map((o) => o.id).toSet();
    for (final id in vecchiIds.difference(nuoviIds)) {
      await _obiettivoRepository.eliminaObiettivo(id);
    }

    _obiettivi = List.from(updatedList);
    notifyListeners();

    for (final o in _obiettivi) {
      await _obiettivoRepository.salvaObiettivo(o);
    }
    await _caricaDati();
  }

  Future<void> refresh() async {
    await _caricaDati();
  }
}
