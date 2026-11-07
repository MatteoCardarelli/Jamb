/// Esito dell'appello di un ragazzo a un evento.
enum StatoPresenza { presente, assente, giustificato }

/// Assenze non giustificate consecutive oltre le quali un ragazzo va
/// segnalato ai capi.
const int sogliaAssenzeRipetute = 3;

/// Presenza di un ragazzo a un evento, nello storico del ragazzo.
class PresenzaRagazzo {
  final String eventoId;
  final String titoloEvento;
  final DateTime dataEvento;
  final StatoPresenza stato;

  const PresenzaRagazzo({
    required this.eventoId,
    required this.titoloEvento,
    required this.dataEvento,
    required this.stato,
  });
}

/// Assenze non giustificate consecutive, contate dall'evento più recente
/// già iniziato all'indietro.
///
/// Una presenza interrompe la serie; un'assenza giustificata non la
/// interrompe e non la allunga (il ragazzo ha avvisato, ma non è venuto).
/// Gli eventi futuri sono ignorati: un'assenza giustificata in anticipo non
/// dice ancora nulla.
int assenzeConsecutive(Iterable<PresenzaRagazzo> storico, {DateTime? adesso}) {
  final ora = adesso ?? DateTime.now();
  final passate = storico.where((p) => !p.dataEvento.isAfter(ora)).toList()
    ..sort((a, b) => b.dataEvento.compareTo(a.dataEvento));

  var assenze = 0;
  for (final presenza in passate) {
    switch (presenza.stato) {
      case StatoPresenza.presente:
        return assenze;
      case StatoPresenza.assente:
        assenze++;
      case StatoPresenza.giustificato:
        break;
    }
  }
  return assenze;
}
