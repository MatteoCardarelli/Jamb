/// Intestazione del Progetto Educativo di Gruppo.
class Peg {
  final String titolo;
  final String premessa;

  const Peg({this.titolo = '', this.premessa = ''});
}

/// Obiettivo del Progetto Educativo di Gruppo.
class PegObiettivo {
  final String id;
  final String titolo;
  final String descrizione;

  const PegObiettivo({required this.id, required this.titolo, this.descrizione = ''});
}

/// Grado di un obiettivo del Programma d'Unità collegato al PEG.
class GradoCollegato {
  final String pegObiettivoId;
  final int grado;

  const GradoCollegato({required this.pegObiettivoId, required this.grado});
}

/// Sotto questa media un obiettivo del PEG è un punto critico (gradi da 1 a 5).
const double sogliaCriticaPeg = 2.5;

/// Avanzamento di un obiettivo del PEG, calcolato dai Programmi d'Unità.
class AvanzamentoPeg {
  final PegObiettivo obiettivo;
  final List<int> gradi;

  const AvanzamentoPeg({required this.obiettivo, required this.gradi});

  /// Media dei gradi collegati; `null` se nessun obiettivo è collegato.
  double? get media =>
      gradi.isEmpty ? null : gradi.reduce((a, b) => a + b) / gradi.length;

  /// Avanzamento da 0 a 1 (grado 1 = 0, grado 5 = 1), `null` senza collegati.
  double? get frazione {
    final m = media;
    return m == null ? null : ((m - 1) / 4).clamp(0.0, 1.0);
  }

  /// `true` se nessuna unità ci lavora o se la media è sotto la soglia (US11).
  bool get critico {
    final m = media;
    return m == null || m < sogliaCriticaPeg;
  }
}

/// Avanzamento di ogni obiettivo del PEG; i gradi di obiettivi non più
/// esistenti si ignorano.
List<AvanzamentoPeg> calcolaAvanzamentoPeg(
  Iterable<PegObiettivo> obiettivi,
  Iterable<GradoCollegato> collegati,
) {
  final perObiettivo = <String, List<int>>{};
  for (final c in collegati) {
    perObiettivo.putIfAbsent(c.pegObiettivoId, () => []).add(c.grado);
  }
  return [
    for (final o in obiettivi)
      AvanzamentoPeg(obiettivo: o, gradi: perObiettivo[o.id] ?? const []),
  ];
}
