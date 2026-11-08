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

  /// Serie a cui appartiene l'evento se si ripete (`null` se è singolo):
  /// ogni data della ripetizione è un evento a sé, con il suo appello.
  final String? serieId;

  /// Ogni quanto si ripete la serie ([Ripetizione.mai] per un evento singolo).
  final Ripetizione ripetizione;

  /// Calendario a cui appartiene: l'unità attiva, la Co.Ca. o il gruppo.
  final LivelloEvento livello;

  const Evento({
    required this.id,
    required this.titolo,
    required this.dataInizio,
    required this.dataFine,
    required this.luogo,
    required this.categorie,
    required this.colorePrincipale,
    this.tuttoIlGiorno = false,
    this.serieId,
    this.ripetizione = Ripetizione.mai,
    this.livello = LivelloEvento.unita,
  });

  /// `true` se l'evento fa parte di una ripetizione.
  bool get inSerie => serieId != null;

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
    String? serieId,
    Ripetizione? ripetizione,
    LivelloEvento? livello,
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
      serieId: serieId ?? this.serieId,
      ripetizione: ripetizione ?? this.ripetizione,
      livello: livello ?? this.livello,
    );
  }
}

/// Calendario a cui appartiene un evento.
enum LivelloEvento {
  /// Dell'unità attiva.
  unita(''),

  /// Della Comunità Capi: lo vedono e lo modificano tutti i capi del gruppo.
  coca('Co.Ca.'),

  /// Di tutto il gruppo, senza unità.
  gruppo('Gruppo');

  /// Etichetta che distingue l'evento negli elenchi (vuota per l'unità).
  final String etichetta;
  const LivelloEvento(this.etichetta);
}

/// Quali eventi mostra il calendario.
enum FiltroCalendario {
  tutti('Tutti'),
  unita('La mia unità'),
  coca('Co.Ca.');

  final String etichetta;
  const FiltroCalendario(this.etichetta);

  /// `true` se [evento] rientra nel filtro. Gli eventi di gruppo riguardano
  /// i capi come quelli di Co.Ca.
  bool include(Evento evento) => switch (this) {
        FiltroCalendario.tutti => true,
        FiltroCalendario.unita => evento.livello == LivelloEvento.unita,
        FiltroCalendario.coca => evento.livello != LivelloEvento.unita,
      };
}

/// Ogni quanto si ripete un evento.
enum Ripetizione { mai, ogniGiorno, ogniSettimana, ogniMese, ogniAnno }

/// Su quali eventi di una serie agisce una modifica o un'eliminazione.
enum AmbitoSerie { soloQuesto, questoESuccessivi }

/// Numero massimo di date create per una ripetizione (un anno di eventi
/// giornalieri): evita serie infinite per una data di fine sbagliata.
const int massimoRipetizioni = 366;

/// Giorno di [d] alle 00:00, per confrontare e contare giorni di calendario.
DateTime _giorno(DateTime d) => DateTime(d.year, d.month, d.day);

/// Giorni di calendario da [da] ad [a] (indipendente dall'ora legale).
int _giorniTra(DateTime da, DateTime a) =>
    DateTime.utc(a.year, a.month, a.day).difference(DateTime.utc(da.year, da.month, da.day)).inDays;

/// Data della [i]-esima ripetizione (0 = [inizio]) con la stessa ora di [inizio].
///
/// Mesi e anni si contano dalla data di partenza, non dalla ripetizione
/// precedente: un evento del 31 gennaio cade il 28 (o 29) febbraio e torna
/// al 31 marzo; uno del 29 febbraio cade il 28 negli anni non bisestili.
DateTime _ripetizione(DateTime inizio, Ripetizione ripetizione, int i) {
  DateTime conGiorno(int anno, int mese) {
    final ultimo = DateTime(anno, mese + 1, 0).day;
    final giorno = inizio.day > ultimo ? ultimo : inizio.day;
    return DateTime(anno, mese, giorno, inizio.hour, inizio.minute);
  }

  return switch (ripetizione) {
    Ripetizione.mai => inizio,
    Ripetizione.ogniGiorno =>
      DateTime(inizio.year, inizio.month, inizio.day + i, inizio.hour, inizio.minute),
    Ripetizione.ogniSettimana =>
      DateTime(inizio.year, inizio.month, inizio.day + 7 * i, inizio.hour, inizio.minute),
    Ripetizione.ogniMese => conGiorno(inizio.year, inizio.month + i),
    Ripetizione.ogniAnno => conGiorno(inizio.year + i, inizio.month),
  };
}

/// Le date della serie che parte da [evento] e si ripete fino al giorno
/// [finoAl] incluso, al massimo [massimoRipetizioni]: ognuna con la stessa
/// ora e la stessa durata in giorni del primo evento. Senza ripetizione
/// restituisce il solo [evento].
List<Evento> eventiDellaSerie(Evento evento, Ripetizione ripetizione, DateTime finoAl) {
  if (ripetizione == Ripetizione.mai) return [evento];
  final ultimoGiorno = _giorno(finoAl);
  final eventi = <Evento>[];
  for (var i = 0; i < massimoRipetizioni; i++) {
    final inizio = _ripetizione(evento.dataInizio, ripetizione, i);
    if (_giorno(inizio).isAfter(ultimoGiorno)) break;
    eventi.add(spostaAlGiorno(evento, inizio).copyWith(ripetizione: ripetizione));
  }
  return eventi;
}

/// [modello] spostato al giorno di [giorno], con la stessa ora di inizio e
/// fine e la stessa durata in giorni: usato per creare le ripetizioni e per
/// applicare una modifica agli eventi successivi della serie.
Evento spostaAlGiorno(Evento modello, DateTime giorno) {
  final durata = _giorniTra(modello.dataInizio, modello.dataFine);
  final i = modello.dataInizio;
  final f = modello.dataFine;
  return modello.copyWith(
    dataInizio: DateTime(giorno.year, giorno.month, giorno.day, i.hour, i.minute),
    dataFine: DateTime(giorno.year, giorno.month, giorno.day + durata, f.hour, f.minute),
  );
}

/// [occorrenza] di una serie dopo la modifica «questo e i successivi» fatta
/// su un altro evento ([modificato]): prende titolo, luogo, categorie,
/// orari e durata, ma resta nel suo giorno e nella sua serie.
Evento applicaAllaSerie(Evento modificato, Evento occorrenza) =>
    spostaAlGiorno(modificato, occorrenza.dataInizio).copyWith(
      id: occorrenza.id,
      serieId: occorrenza.serieId,
      ripetizione: occorrenza.ripetizione,
    );
