import 'package:flutter/material.dart';
import 'package:jamb/ui/views/amministrazione/widgets/status_row_card.dart';

class RagazzoDocumenti {
  final String id;
  final String initials;
  final String nome;
  DocumentStatus censimento;
  DocumentStatus privacy;
  DocumentStatus medica;

  RagazzoDocumenti({
    required this.id,
    required this.initials,
    required this.nome,
    this.censimento = DocumentStatus.none,
    this.privacy = DocumentStatus.none,
    this.medica = DocumentStatus.none,
  });
}

class AmministrazioneProvider extends ChangeNotifier {
  final List<RagazzoDocumenti> _ragazzi = [
    RagazzoDocumenti(
      id: "1",
      initials: "MR",
      nome: "Marco Rossini",
      censimento: DocumentStatus.none,
      privacy: DocumentStatus.valid,
      medica: DocumentStatus.valid,
    ),
    RagazzoDocumenti(
      id: "2",
      initials: "GB",
      nome: "Giulia Bianchi",
      censimento: DocumentStatus.valid,
      privacy: DocumentStatus.valid,
      medica: DocumentStatus.missing,
    ),
    RagazzoDocumenti(
      id: "3",
      initials: "LV",
      nome: "Luca Verdi",
      censimento: DocumentStatus.none,
      privacy: DocumentStatus.valid,
      medica: DocumentStatus.valid,
    ),
    RagazzoDocumenti(
      id: "4",
      initials: "SN",
      nome: "Sara Neri",
      censimento: DocumentStatus.valid,
      privacy: DocumentStatus.valid,
      medica: DocumentStatus.valid,
    ),
    RagazzoDocumenti(
      id: "5",
      initials: "DG",
      nome: "Davide Gialli",
      censimento: DocumentStatus.valid,
      privacy: DocumentStatus.expiring,
      medica: DocumentStatus.valid,
    ),
  ];

  List<RagazzoDocumenti> get ragazzi => _ragazzi;

  // Calcolo statistiche globali
  int get totali => _ragazzi.length;
  
  int get censValid => _ragazzi.where((r) => 
    r.censimento == DocumentStatus.valid || r.censimento == DocumentStatus.expiring).length;
    
  int get privValid => _ragazzi.where((r) => 
    r.privacy == DocumentStatus.valid || r.privacy == DocumentStatus.expiring).length;
    
  int get medValid => _ragazzi.where((r) => 
    r.medica == DocumentStatus.valid || r.medica == DocumentStatus.expiring).length;

  // Calcolo progresso globale Amministrazione (Ragazzi che hanno TUTTO ok)
  int get ragazziTuttoOk => _ragazzi.where((r) {
    bool c = r.censimento == DocumentStatus.valid || r.censimento == DocumentStatus.expiring;
    bool p = r.privacy == DocumentStatus.valid || r.privacy == DocumentStatus.expiring;
    bool m = r.medica == DocumentStatus.valid || r.medica == DocumentStatus.expiring;
    return c && p && m;
  }).length;

  /// Restituisce un messaggio riassuntivo degli avvisi amministrativi (schede mediche, censimenti).
  String get alertMessage {
    int medScadute = _ragazzi.where((e) => e.medica == DocumentStatus.missing).length;
    int medInScadenza = _ragazzi.where((e) => e.medica == DocumentStatus.expiring).length;
    int censMancanti = _ragazzi.where((e) => e.censimento == DocumentStatus.none || e.censimento == DocumentStatus.missing).length;

    List<String> alerts = [];
    if (medScadute > 0) alerts.add("$medScadute schede mediche scadute");
    if (medInScadenza > 0) alerts.add("$medInScadenza in scadenza");
    if (censMancanti > 0) alerts.add("$censMancanti censimenti mancanti");

    return alerts.isNotEmpty ? "${alerts.join(", ")}." : "";
  }

  void cycleStatus(String id, String field) {
    final index = _ragazzi.indexWhere((r) => r.id == id);
    if (index != -1) {
      DocumentStatus currentStatus;
      if (field == 'censimento') currentStatus = _ragazzi[index].censimento;
      else if (field == 'privacy') currentStatus = _ragazzi[index].privacy;
      else currentStatus = _ragazzi[index].medica;

      DocumentStatus nextStatus;
      switch (currentStatus) {
        case DocumentStatus.none: nextStatus = DocumentStatus.valid; break;
        case DocumentStatus.valid: nextStatus = DocumentStatus.expiring; break;
        case DocumentStatus.expiring: nextStatus = DocumentStatus.missing; break;
        case DocumentStatus.missing: nextStatus = DocumentStatus.none; break;
      }

      if (field == 'censimento') _ragazzi[index].censimento = nextStatus;
      else if (field == 'privacy') _ragazzi[index].privacy = nextStatus;
      else _ragazzi[index].medica = nextStatus;

      notifyListeners();
    }
  }
}
