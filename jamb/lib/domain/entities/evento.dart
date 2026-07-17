import 'package:flutter/material.dart';

/// Categoria tematica di un evento, con i colori usati per rappresentarla.
enum CategoriaEvento {
  spiritualita('SPIRITUALITÀ', Color(0xFFE8EAF6), Color(0xFF283593)),
  competenza('COMPETENZA', Color(0xFFE8F5E9), Color(0xFF2E7D32)),
  servizio('SERVIZIO', Color(0xFFFFF3E0), Color(0xFFD84315)),
  altro('ALTRO', Color(0xFFEEEEEE), Color(0xFF616161));

  final String nome;
  final Color backgroundColor;
  final Color textColor;

  const CategoriaEvento(this.nome, this.backgroundColor, this.textColor);

  /// Restituisce la categoria corrispondente al [nome] (case-insensitive),
  /// oppure [CategoriaEvento.altro] se non riconosciuto.
  static CategoriaEvento fromString(String nome) {
    return CategoriaEvento.values.firstWhere(
      (e) => e.nome.toUpperCase() == nome.toUpperCase(),
      orElse: () => CategoriaEvento.altro,
    );
  }
}

/// Evento del calendario di reparto (riunione, uscita, campo, ...).
class Evento {
  final String id;
  final String titolo;
  final DateTime dataInizio;
  final DateTime dataFine;
  final String luogo;
  final List<CategoriaEvento> categorie;
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
    List<CategoriaEvento>? categorie,
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

  /// Serializza l'evento in una mappa chiave-valore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titolo': titolo,
      'dataInizio': dataInizio.toIso8601String(),
      'dataFine': dataFine.toIso8601String(),
      'luogo': luogo,
      'categorie': categorie.map((e) => e.nome).toList(),
      'colorePrincipale': colorePrincipale.value,
    };
  }

  /// Costruisce un evento a partire da una mappa serializzata.
  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      id: map['id'] ?? '',
      titolo: map['titolo'] ?? '',
      dataInizio: DateTime.parse(map['dataInizio']),
      dataFine: DateTime.parse(map['dataFine']),
      luogo: map['luogo'] ?? '',
      categorie: (map['categorie'] as List?)?.map((e) => CategoriaEvento.fromString(e)).toList() ?? [],
      colorePrincipale: Color(map['colorePrincipale'] ?? 0xFF25315B),
    );
  }
}
