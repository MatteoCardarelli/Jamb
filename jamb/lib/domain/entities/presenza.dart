import 'evento.dart';

/// Esito dell'appello di un ragazzo a un evento.
enum StatoPresenza { presente, assente, giustificato }

/// Anticipo con cui un evento diventa quello dell'appello dalla Home.
const Duration anticipoAppello = Duration(hours: 1);

/// Quanto indietro si cerca l'ultimo evento, per un appello compilato dopo.
const Duration finestraAppelloRecente = Duration(days: 7);

/// Evento di cui aprire l'appello dall'azione rapida della Home:
/// 1. quello in corso (il più recente, se sono più d'uno);
/// 2. altrimenti il primo che inizia entro [anticipoAppello];
/// 3. altrimenti l'ultimo iniziato negli ultimi [finestraAppelloRecente].
/// `null` se non ce n'è nessuno: l'appello si apre allora dal calendario.
Evento? eventoPerAppello(Iterable<Evento> eventi, DateTime adesso) {
  final iniziati = eventi.where((e) => !e.dataInizio.isAfter(adesso)).toList()
    ..sort((a, b) => b.dataInizio.compareTo(a.dataInizio));

  for (final e in iniziati) {
    if (!e.dataFine.isBefore(adesso)) return e; // in corso
  }

  final imminenti = eventi
      .where((e) =>
          e.dataInizio.isAfter(adesso) &&
          !e.dataInizio.isAfter(adesso.add(anticipoAppello)))
      .toList()
    ..sort((a, b) => a.dataInizio.compareTo(b.dataInizio));
  if (imminenti.isNotEmpty) return imminenti.first;

  final limite = adesso.subtract(finestraAppelloRecente);
  for (final e in iniziati) {
    if (!e.dataInizio.isBefore(limite)) return e;
  }
  return null;
}

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
