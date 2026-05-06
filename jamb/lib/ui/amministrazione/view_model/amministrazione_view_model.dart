import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/entities/progresso.dart';

/// ViewModel per la gestione della logica amministrativa.
/// Gestisce l'elenco degli scout e i loro stati documentali (Censimento, Privacy, Medica).
class AmministrazioneViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<Scout> _ragazzi = [
    Scout(
      id: "1",
      nome: "Marco Rossini",
      squadriglia: "Volpi",
      ruolo: "Capo Squadriglia",
      progresso: const ProgressoScout(),
      statoCensimento: DocumentoStatus.nessuno,
      statoPrivacy: DocumentoStatus.valido,
      statoMedica: DocumentoStatus.valido,
    ),
    Scout(
      id: "2",
      nome: "Giulia Bianchi",
      squadriglia: "Aquile",
      ruolo: "Vice Capo",
      progresso: const ProgressoScout(),
      statoCensimento: DocumentoStatus.valido,
      statoPrivacy: DocumentoStatus.valido,
      statoMedica: DocumentoStatus.scaduto,
    ),
    Scout(
      id: "3",
      nome: "Luca Verdi",
      squadriglia: "Volpi",
      ruolo: "Esploratore",
      progresso: const ProgressoScout(),
      statoCensimento: DocumentoStatus.nessuno,
      statoPrivacy: DocumentoStatus.valido,
      statoMedica: DocumentoStatus.valido,
    ),
    Scout(
      id: "4",
      nome: "Sara Neri",
      squadriglia: "Aquile",
      ruolo: "Squadrigliere",
      progresso: const ProgressoScout(),
      statoCensimento: DocumentoStatus.valido,
      statoPrivacy: DocumentoStatus.valido,
      statoMedica: DocumentoStatus.valido,
    ),
    Scout(
      id: "5",
      nome: "Davide Gialli",
      squadriglia: "Pantere",
      ruolo: "Capo Squadriglia",
      progresso: const ProgressoScout(),
      statoCensimento: DocumentoStatus.valido,
      statoPrivacy: DocumentoStatus.inScadenza,
      statoMedica: DocumentoStatus.valido,
    ),
  ];

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

  /// Restituisce un messaggio riassuntivo degli avvisi amministrativi (schede mediche, censimenti).
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

  /// Metodi per aggiornare lo stato (ciclo)
  void updateCensimento(String id) => _cycleStatus(id, 'censimento');
  void updatePrivacy(String id) => _cycleStatus(id, 'privacy');
  void updateMedica(String id) => _cycleStatus(id, 'medica');

  void _cycleStatus(String id, String field) {
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

      if (field == 'censimento') {
        _ragazzi[index] = _ragazzi[index].copyWith(statoCensimento: nextStatus);
      } else if (field == 'privacy') {
        _ragazzi[index] = _ragazzi[index].copyWith(statoPrivacy: nextStatus);
      } else {
        _ragazzi[index] = _ragazzi[index].copyWith(statoMedica: nextStatus);
      }

      notifyListeners();
    }
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
