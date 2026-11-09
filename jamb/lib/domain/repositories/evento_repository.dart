import 'package:flutter/foundation.dart';
import '../../domain/entities/evento.dart';

/// Contratto per l'accesso agli eventi del calendario.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IEventoRepository extends ChangeNotifier {
  /// Crea un nuovo evento nell'unità attiva. Con una [ripetizione] crea in
  /// un'unica scrittura tutte le date fino al giorno [finoAl], in una serie.
  Future<void> creaEvento(
    Evento evento, {
    Ripetizione ripetizione = Ripetizione.mai,
    DateTime? finoAl,
  });

  /// Aggiorna l'evento esistente con lo stesso id di [evento]; con
  /// [AmbitoSerie.questoESuccessivi] porta la modifica anche sugli eventi
  /// successivi della sua serie, ciascuno nel suo giorno.
  Future<void> aggiornaEvento(Evento evento, {AmbitoSerie ambito = AmbitoSerie.soloQuesto});

  /// Elimina [evento]; con [AmbitoSerie.questoESuccessivi] anche gli eventi
  /// successivi della sua serie.
  Future<void> eliminaEvento(Evento evento, {AmbitoSerie ambito = AmbitoSerie.soloQuesto});

  /// Tutti gli eventi visibili, ordinati per data di inizio crescente.
  Future<List<Evento>> getEventi();
}
