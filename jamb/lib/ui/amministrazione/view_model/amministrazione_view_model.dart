import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';

/// ViewModel per la gestione della logica amministrativa.
/// Ora reattivo: ascolta i cambiamenti del repository per restare sempre aggiornato.
class AmministrazioneViewModel extends ChangeNotifier {
  final IScoutRepository _repository;
  
  List<Scout> _ragazzi = [];
  bool _isLoading = true;

  AmministrazioneViewModel(this._repository) {
    _repository.addListener(_caricaDati);
    _caricaDati();
  }

  @override
  void dispose() {
    _repository.removeListener(_caricaDati);
    super.dispose();
  }

  Future<void> _caricaDati() async {
    _isLoading = true;
    notifyListeners();
    _ragazzi = await _repository.getRagazzi();
    _isLoading = false;
    notifyListeners();
  }

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  List<Scout> get ragazzi => _ragazzi;

  // Calcolo statistiche globali
  int get totali => _ragazzi.length;
  
  int get censValid => _ragazzi.where((r) => 
    r.statoCensimento == DocumentoStatus.valido || r.statoCensimento == DocumentoStatus.inScadenza).length;
    
  int get privValid => _ragazzi.where((r) => 
    r.statoPrivacy == DocumentoStatus.valido || r.statoPrivacy == DocumentoStatus.inScadenza).length;
    
  int get medValid => _ragazzi.where((r) => 
    r.statoMedica == DocumentoStatus.valido || r.statoMedica == DocumentoStatus.inScadenza).length;

  int get ragazziTuttoOk => _ragazzi.where((r) {
    bool c = r.statoCensimento == DocumentoStatus.valido || r.statoCensimento == DocumentoStatus.inScadenza;
    bool p = r.statoPrivacy == DocumentoStatus.valido || r.statoPrivacy == DocumentoStatus.inScadenza;
    bool m = r.statoMedica == DocumentoStatus.valido || r.statoMedica == DocumentoStatus.inScadenza;
    return c && p && m;
  }).length;

  /// Restituisce un messaggio riassuntivo degli avvisi amministrativi.
  String get alertMessage {
    int medScadute = _ragazzi.where((e) => e.statoMedica == DocumentoStatus.scaduto).length;
    int medInScadenza = _ragazzi.where((e) => e.statoMedica == DocumentoStatus.inScadenza).length;
    int censMancanti = _ragazzi.where((e) => e.statoCensimento == DocumentoStatus.nessuno || e.statoCensimento == DocumentoStatus.scaduto).length;

    List<String> alerts = [];
    if (medScadute > 0) alerts.add("$medScadute schede mediche scadute");
    if (medInScadenza > 0) alerts.add("$medInScadenza in scadenza");
    if (censMancanti > 0) alerts.add("$censMancanti censimenti mancanti");

    return alerts.isNotEmpty ? "${alerts.join(", ")}." : "";
  }

  // --- AZIONI ---

  Future<void> updateCensimento(String id) => _cycleStatus(id, 'censimento');
  Future<void> updatePrivacy(String id) => _cycleStatus(id, 'privacy');
  Future<void> updateMedica(String id) => _cycleStatus(id, 'medica');

  Future<void> _cycleStatus(String id, String field) async {
    final index = _ragazzi.indexWhere((r) => r.id == id);
    if (index != -1) {
      DocumentoStatus currentStatus;
      if (field == 'censimento') currentStatus = _ragazzi[index].statoCensimento;
      else if (field == 'privacy') currentStatus = _ragazzi[index].statoPrivacy;
      else currentStatus = _ragazzi[index].statoMedica;

      DocumentoStatus nextStatus;
      switch (currentStatus) {
        case DocumentoStatus.nessuno: nextStatus = DocumentoStatus.valido; break;
        case DocumentoStatus.valido: nextStatus = DocumentoStatus.inScadenza; break;
        case DocumentoStatus.inScadenza: nextStatus = DocumentoStatus.scaduto; break;
        case DocumentoStatus.scaduto: nextStatus = DocumentoStatus.nessuno; break;
      }

      Scout updatedScout;
      if (field == 'censimento') {
        updatedScout = _ragazzi[index].copyWith(statoCensimento: nextStatus);
      } else if (field == 'privacy') {
        updatedScout = _ragazzi[index].copyWith(statoPrivacy: nextStatus);
      } else {
        updatedScout = _ragazzi[index].copyWith(statoMedica: nextStatus);
      }

      await _repository.salvaRagazzo(updatedScout);
      // Non serve chiamare _caricaDati() qui, perché l'addListener lo farà per noi!
    }
  }

  Future<void> refresh() async {
    await _caricaDati();
  }
}
