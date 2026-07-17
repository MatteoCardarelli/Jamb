import 'package:flutter/material.dart';

/// Obiettivo educativo dell'unità, definito per dominio (Spiritualità,
/// Competenza, Servizio, ...) con un grado di raggiungimento e un diario.
class Obiettivo {
  final String id;
  final String dominio;
  final String descrizione;
  final int grado; // da 1 a 5
  final Color colore;
  final IconData icona;
  final String diarioDiBordo;

  const Obiettivo({
    required this.id,
    required this.dominio,
    required this.descrizione,
    required this.grado,
    required this.colore,
    required this.icona,
    this.diarioDiBordo = "",
  });

  /// Restituisce una copia dell'obiettivo con i campi indicati sostituiti.
  Obiettivo copyWith({
    String? id,
    String? dominio,
    String? descrizione,
    int? grado,
    Color? colore,
    IconData? icona,
    String? diarioDiBordo,
  }) {
    return Obiettivo(
      id: id ?? this.id,
      dominio: dominio ?? this.dominio,
      descrizione: descrizione ?? this.descrizione,
      grado: grado ?? this.grado,
      colore: colore ?? this.colore,
      icona: icona ?? this.icona,
      diarioDiBordo: diarioDiBordo ?? this.diarioDiBordo,
    );
  }

  /// Serializza l'obiettivo in una mappa chiave-valore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dominio': dominio,
      'descrizione': descrizione,
      'grado': grado,
      'colore': colore.value,
      'icona': icona.codePoint,
      'diarioDiBordo': diarioDiBordo,
    };
  }

  /// Costruisce un obiettivo a partire da una mappa serializzata.
  factory Obiettivo.fromMap(Map<String, dynamic> map) {
    return Obiettivo(
      id: map['id'],
      dominio: map['dominio'],
      descrizione: map['descrizione'],
      grado: map['grado'],
      colore: Color(map['colore']),
      icona: IconData(map['icona'], fontFamily: 'MaterialIcons'),
      diarioDiBordo: map['diarioDiBordo'] ?? "",
    );
  }
}
