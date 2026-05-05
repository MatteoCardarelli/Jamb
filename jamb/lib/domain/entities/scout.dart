import 'package:flutter/material.dart';

/// Definiamo gli stati possibili per i documenti scout
enum DocumentoStatus { 
  nessuno, 
  valido, 
  inScadenza, 
  scaduto 
}

class ContattoEmergenza {
  final String nome;
  final String telefono;

  const ContattoEmergenza({
    required this.nome, 
    required this.telefono
  });
}

class Scout {
  final String id;
  final String nome;
  final String squadriglia;
  final String ruolo;
  final String? allergie;
  
  // Stato Amministrativo
  final DocumentoStatus statoCensimento;
  final DocumentoStatus statoPrivacy;
  final DocumentoStatus statoMedica;
  
  // Date di scadenza
  final DateTime? scadenzaPrivacy;
  final DateTime? scadenzaMedica;

  // Lista di contatti
  final List<ContattoEmergenza> contattiEmergenza;

  // Costruttore
  const Scout({
    required this.id,
    required this.nome,
    required this.squadriglia,
    required this.ruolo,
    this.allergie,
    this.statoCensimento = DocumentoStatus.nessuno,
    this.statoPrivacy = DocumentoStatus.nessuno,
    this.statoMedica = DocumentoStatus.nessuno,
    this.scadenzaPrivacy,
    this.scadenzaMedica,
    this.contattiEmergenza = const [],
  });

  String get iniziali {
    if (nome.isEmpty) return "??";
    List<String> parti = nome.trim().split(" ");
    if (parti.length < 2) return nome.substring(0, 1).toUpperCase();
    return (parti[0][0] + parti[parti.length - 1][0]).toUpperCase();
  }

  Scout copyWith({
    String? nome,
    String? squadriglia,
    String? ruolo,
    String? allergie,
    DocumentoStatus? statoCensimento,
    DocumentoStatus? statoPrivacy,
    DocumentoStatus? statoMedica,
    DateTime? scadenzaPrivacy,
    DateTime? scadenzaMedica,
    List<ContattoEmergenza>? contattiEmergenza,
  }) {
    return Scout(
      id: id,
      nome: nome ?? this.nome,
      squadriglia: squadriglia ?? this.squadriglia,
      ruolo: ruolo ?? this.ruolo,
      allergie: allergie ?? this.allergie,
      statoCensimento: statoCensimento ?? this.statoCensimento,
      statoPrivacy: statoPrivacy ?? this.statoPrivacy,
      statoMedica: statoMedica ?? this.statoMedica,
      scadenzaPrivacy: scadenzaPrivacy ?? this.scadenzaPrivacy,
      scadenzaMedica: scadenzaMedica ?? this.scadenzaMedica,
      contattiEmergenza: contattiEmergenza ?? this.contattiEmergenza,
    );
  }
}
