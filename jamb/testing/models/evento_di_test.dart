import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/evento.dart';

/// Crea un [Evento] di test da [inizio] a [fine] (di default un'ora dopo).
Evento eventoDiTest(
  String id,
  DateTime inizio, {
  DateTime? fine,
  LivelloEvento livello = LivelloEvento.unita,
}) {
  return Evento(
    id: id,
    titolo: id,
    dataInizio: inizio,
    dataFine: fine ?? inizio.add(const Duration(hours: 1)),
    luogo: 'Sede',
    categorie: const ['Altro'],
    colorePrincipale: Colors.blue,
    livello: livello,
  );
}
