import 'package:flutter/material.dart';

class Obiettivo {
  final String id;
  final String dominio;
  final String descrizione;
  final int grado; // 1 to 5
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
}
