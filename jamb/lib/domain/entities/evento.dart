import 'package:flutter/material.dart';

/// Evento del calendario di reparto (riunione, uscita, campo, ...).
///
/// Le categorie tematiche non sono un insieme fisso: corrispondono ai domini
/// degli obiettivi del Programma d'Unità, più la voce trasversale "Altro".
class Evento {
  final String id;
  final String titolo;
  final DateTime dataInizio;
  final DateTime dataFine;
  final String luogo;
  final List<String> categorie;
  final Color colorePrincipale;

  const Evento({
    required this.id,
    required this.titolo,
    required this.dataInizio,
    required this.dataFine,
    required this.luogo,
    required this.categorie,
    required this.colorePrincipale,
  });

  /// Restituisce una copia dell'evento con i campi indicati sostituiti.
  Evento copyWith({
    String? id,
    String? titolo,
    DateTime? dataInizio,
    DateTime? dataFine,
    String? luogo,
    List<String>? categorie,
    Color? colorePrincipale,
  }) {
    return Evento(
      id: id ?? this.id,
      titolo: titolo ?? this.titolo,
      dataInizio: dataInizio ?? this.dataInizio,
      dataFine: dataFine ?? this.dataFine,
      luogo: luogo ?? this.luogo,
      categorie: categorie ?? this.categorie,
      colorePrincipale: colorePrincipale ?? this.colorePrincipale,
    );
  }
}
