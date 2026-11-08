/// Lunghezza massima di una pillola (come il vincolo su `pillole.testo`).
const int lunghezzaMassimaPillola = 500;

/// Breve nozione sul metodo di una branca (US8).
class Pillola {
  final String id;
  final String testo;

  /// `true` se è comune a tutti i gruppi: si legge ma non si modifica.
  final bool comune;

  const Pillola({required this.id, required this.testo, this.comune = false});
}

/// Motivo per cui [testo] non va bene, oppure `null`.
String? errorePillola(String testo) {
  final pulito = testo.trim();
  if (pulito.isEmpty) return 'Il testo non può essere vuoto.';
  if (pulito.length > lunghezzaMassimaPillola) {
    return 'Il testo è troppo lungo (massimo $lunghezzaMassimaPillola caratteri).';
  }
  return null;
}

/// Pillola del giorno [data]: dipende solo dal giorno di calendario e
/// dall'insieme delle [pillole], non dall'ora né dall'ordine in cui arrivano.
/// `null` se non ce ne sono.
Pillola? pillolaDelGiorno(Iterable<Pillola> pillole, DateTime data) {
  if (pillole.isEmpty) return null;
  final ordinate = pillole.toList()..sort((a, b) => a.id.compareTo(b.id));
  // In UTC i giorni durano tutti 24 ore: l'ora legale non salta una pillola.
  final giorno = DateTime.utc(data.year, data.month, data.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  return ordinate[giorno % ordinate.length];
}
