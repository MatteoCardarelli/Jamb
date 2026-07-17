import 'package:flutter/material.dart';
import 'progresso.dart';

/// Stato di un documento amministrativo di uno scout (censimento, privacy, medica).
enum DocumentoStatus {
  nessuno,
  valido,
  inScadenza,
  scaduto;

  /// Converte un nome nel relativo stato; per un valore sconosciuto
  /// restituisce [DocumentoStatus.nessuno].
  static DocumentoStatus safeByName(String name) {
    try {
      return DocumentoStatus.values.byName(name);
    } catch (_) {
      return DocumentoStatus.nessuno;
    }
  }
}

/// Contatto di emergenza associato a uno scout (es. un genitore).
class ContattoEmergenza {
  final String nome;
  final String telefono;

  const ContattoEmergenza({
    required this.nome,
    required this.telefono,
  });

  /// Serializza il contatto in una mappa chiave-valore.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefono': telefono,
    };
  }

  /// Costruisce un contatto a partire da una mappa serializzata.
  factory ContattoEmergenza.fromMap(Map<String, dynamic> map) {
    return ContattoEmergenza(
      nome: map['nome'] ?? '',
      telefono: map['telefono'] ?? '',
    );
  }
}

/// Profilo completo di uno scout: anagrafica, progressione, stato
/// amministrativo dei documenti e contatti di emergenza.
///
/// È un modello "piatto" pensato per la UI: il repository lo ricompone
/// leggendo da più tabelle normalizzate del database.
class Scout {
  final String id;
  final String nome;
  final String squadriglia;
  final String ruolo;
  final String? allergie;
  final ProgressoScout progresso;

  // Stato amministrativo dei documenti.
  final DocumentoStatus statoCensimento;
  final DocumentoStatus statoPrivacy;
  final DocumentoStatus statoMedica;

  // Date di scadenza dei documenti.
  final DateTime? scadenzaPrivacy;
  final DateTime? scadenzaMedica;

  final List<ContattoEmergenza> contattiEmergenza;

  const Scout({
    required this.id,
    required this.nome,
    required this.squadriglia,
    required this.ruolo,
    required this.progresso,
    this.allergie,
    this.statoCensimento = DocumentoStatus.nessuno,
    this.statoPrivacy = DocumentoStatus.nessuno,
    this.statoMedica = DocumentoStatus.nessuno,
    this.scadenzaPrivacy,
    this.scadenzaMedica,
    this.contattiEmergenza = const [],
  });

  /// Iniziali dello scout (prima e ultima parola del nome), per gli avatar.
  String get iniziali {
    if (nome.isEmpty) return "??";
    List<String> parti = nome.trim().split(" ");
    if (parti.length < 2) return nome.substring(0, 1).toUpperCase();
    return (parti[0][0] + parti[parti.length - 1][0]).toUpperCase();
  }

  /// Restituisce una copia dello scout con i campi indicati sostituiti.
  Scout copyWith({
    String? nome,
    String? squadriglia,
    String? ruolo,
    String? allergie,
    ProgressoScout? progresso,
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
      progresso: progresso ?? this.progresso,
      statoCensimento: statoCensimento ?? this.statoCensimento,
      statoPrivacy: statoPrivacy ?? this.statoPrivacy,
      statoMedica: statoMedica ?? this.statoMedica,
      scadenzaPrivacy: scadenzaPrivacy ?? this.scadenzaPrivacy,
      scadenzaMedica: scadenzaMedica ?? this.scadenzaMedica,
      contattiEmergenza: contattiEmergenza ?? this.contattiEmergenza,
    );
  }

  /// Serializza lo scout in una mappa chiave-valore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'squadriglia': squadriglia,
      'ruolo': ruolo,
      'allergie': allergie,
      'progresso': progresso.toMap(),
      'statoCensimento': statoCensimento.name,
      'statoPrivacy': statoPrivacy.name,
      'statoMedica': statoMedica.name,
      'scadenzaPrivacy': scadenzaPrivacy?.toIso8601String(),
      'scadenzaMedica': scadenzaMedica?.toIso8601String(),
      'contattiEmergenza': contattiEmergenza.map((x) => x.toMap()).toList(),
    };
  }

  /// Costruisce uno scout da una mappa serializzata; restituisce `null`
  /// se il parsing fallisce (record malformato).
  static Scout? fromMap(Map<String, dynamic> map) {
    try {
      return Scout(
        id: map['id'],
        nome: map['nome'],
        squadriglia: map['squadriglia'],
        ruolo: map['ruolo'],
        allergie: map['allergie'],
        progresso: ProgressoScout.fromMap(map['progresso']),
        statoCensimento: DocumentoStatus.safeByName(map['statoCensimento'] ?? ''),
        statoPrivacy: DocumentoStatus.safeByName(map['statoPrivacy'] ?? ''),
        statoMedica: DocumentoStatus.safeByName(map['statoMedica'] ?? ''),
        scadenzaPrivacy: map['scadenzaPrivacy'] != null ? DateTime.parse(map['scadenzaPrivacy']) : null,
        scadenzaMedica: map['scadenzaMedica'] != null ? DateTime.parse(map['scadenzaMedica']) : null,
        contattiEmergenza: map['contattiEmergenza'] != null
            ? List<ContattoEmergenza>.from(
                (map['contattiEmergenza'] as List).map((x) => ContattoEmergenza.fromMap(x)),
              )
            : const [],
      );
    } catch (e) {
      debugPrint("Errore nel parsing dello scout ${map['nome']}: $e");
      return null;
    }
  }
}
