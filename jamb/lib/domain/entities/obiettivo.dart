import 'package:flutter/material.dart';

/// Icone che si possono scegliere per un obiettivo, nell'ordine del dialogo.
///
/// Il database salva il codice dell'icona e l'icona si ricostruisce cercandola
/// qui ([iconaObiettivoDaCodice]): un `IconData` costruito al volo impedisce alla
/// compilazione di rilascio di includere solo le icone usate, e la versione
/// web non si compila.
const List<IconData> iconeObiettivo = [
  Icons.church_rounded,
  Icons.handyman_rounded,
  Icons.directions_walk_rounded,
  Icons.local_fire_department_rounded,
  Icons.park_rounded,
  Icons.explore_rounded,
  Icons.favorite_rounded,
  Icons.flag_rounded,
];

/// Icona di un obiettivo nuovo o con un codice sconosciuto.
const IconData iconaObiettivoPredefinita = Icons.star_rounded;

/// Icona con il codice [codice] salvato nel database; un codice assente o
/// sconosciuto degrada a [iconaObiettivoPredefinita].
IconData iconaObiettivoDaCodice(int? codice) {
  for (final icona in iconeObiettivo) {
    if (icona.codePoint == codice) return icona;
  }
  return iconaObiettivoPredefinita;
}

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

  /// Obiettivo del Progetto Educativo di Gruppo a cui è collegato, se c'è.
  final String? pegObiettivoId;

  const Obiettivo({
    required this.id,
    required this.dominio,
    required this.descrizione,
    required this.grado,
    required this.colore,
    required this.icona,
    this.diarioDiBordo = "",
    this.pegObiettivoId,
  });

  static const Object _invariato = Object();

  /// Restituisce una copia dell'obiettivo con i campi indicati sostituiti.
  /// [pegObiettivoId] si può azzerare passando `null`.
  Obiettivo copyWith({
    String? id,
    String? dominio,
    String? descrizione,
    int? grado,
    Color? colore,
    IconData? icona,
    String? diarioDiBordo,
    Object? pegObiettivoId = _invariato,
  }) {
    return Obiettivo(
      id: id ?? this.id,
      dominio: dominio ?? this.dominio,
      descrizione: descrizione ?? this.descrizione,
      grado: grado ?? this.grado,
      colore: colore ?? this.colore,
      icona: icona ?? this.icona,
      diarioDiBordo: diarioDiBordo ?? this.diarioDiBordo,
      pegObiettivoId: identical(pegObiettivoId, _invariato)
          ? this.pegObiettivoId
          : pegObiettivoId as String?,
    );
  }

  /// Serializza l'obiettivo in una mappa chiave-valore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dominio': dominio,
      'descrizione': descrizione,
      'grado': grado,
      'colore': colore.toARGB32(),
      'icona': icona.codePoint,
      'diarioDiBordo': diarioDiBordo,
    };
  }
}
