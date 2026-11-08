import 'package:flutter/foundation.dart';
import '../entities/peg.dart';

/// Contratto per il Progetto Educativo di Gruppo.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IPegRepository extends ChangeNotifier {
  /// Intestazione del PEG del gruppo; vuota se non è ancora stato scritto.
  Future<Peg> getPeg();

  /// Salva l'intestazione del PEG.
  Future<void> salvaPeg(Peg peg);

  /// Obiettivi del PEG, dal più vecchio.
  Future<List<PegObiettivo>> getObiettivi();

  /// Aggiunge un obiettivo.
  Future<void> creaObiettivo(String titolo, String descrizione);

  /// Salva titolo e descrizione di [obiettivo].
  Future<void> aggiornaObiettivo(PegObiettivo obiettivo);

  /// Elimina l'obiettivo [id]; i Programmi d'Unità collegati restano.
  Future<void> eliminaObiettivo(String id);

  /// Gradi degli obiettivi di Programma collegati al PEG che l'utente può
  /// leggere: delle proprie unità, o di tutte per il Capo Gruppo.
  Future<List<GradoCollegato>> getGradiCollegati();
}
