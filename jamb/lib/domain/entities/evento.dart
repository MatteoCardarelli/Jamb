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

  /// Evento di una o più giornate intere, senza orario: [dataInizio] è alle
  /// 00:00 del primo giorno e [dataFine] alle 23:59 dell'ultimo.
  final bool tuttoIlGiorno;

  const Evento({
    required this.id,
    required this.titolo,
    required this.dataInizio,
    required this.dataFine,
    required this.luogo,
    required this.categorie,
    required this.colorePrincipale,
    this.tuttoIlGiorno = false,
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
    bool? tuttoIlGiorno,
  }) {
    return Evento(
      id: id ?? this.id,
      titolo: titolo ?? this.titolo,
      dataInizio: dataInizio ?? this.dataInizio,
      dataFine: dataFine ?? this.dataFine,
      luogo: luogo ?? this.luogo,
      categorie: categorie ?? this.categorie,
      colorePrincipale: colorePrincipale ?? this.colorePrincipale,
      tuttoIlGiorno: tuttoIlGiorno ?? this.tuttoIlGiorno,
    );
  }
}
