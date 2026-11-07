/// Un'unità in cui l'utente può operare, con il suo ruolo lì.
class UnitaDisponibile {
  final String id;
  final String nome;

  /// Ruolo nella membership attiva; `null` per il Capo Gruppo in un'unità
  /// di cui non è membro (vede tutte le unità del gruppo).
  final String? ruolo;

  const UnitaDisponibile({required this.id, required this.nome, this.ruolo});
}

/// Unità da attivare all'accesso: quella salvata l'ultima volta, se è
/// ancora tra le [disponibili]; altrimenti la prima (le unità arrivano in
/// ordine alfabetico, quindi la scelta non dipende dall'ordine del DB).
/// `null` se non ce n'è nessuna.
String? scegliUnitaIniziale(List<UnitaDisponibile> disponibili, String? salvata) {
  if (disponibili.isEmpty) return null;
  if (salvata != null && disponibili.any((u) => u.id == salvata)) return salvata;
  return disponibili.first.id;
}

/// Unità delle membership attive più, per il Capo Gruppo, tutte quelle del
/// gruppo; senza doppioni e in ordine alfabetico.
List<UnitaDisponibile> componiUnitaDisponibili({
  required List<UnitaDisponibile> daMembership,
  List<UnitaDisponibile> delGruppo = const [],
}) {
  final perId = <String, UnitaDisponibile>{
    for (final u in delGruppo) u.id: u,
    // Le membership vincono: portano il ruolo.
    for (final u in daMembership) u.id: u,
  };
  return perId.values.toList()..sort((a, b) => a.nome.compareTo(b.nome));
}
