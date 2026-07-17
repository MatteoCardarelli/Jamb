import 'package:flutter/foundation.dart';
import '../../domain/entities/evento.dart';

/// Contratto per l'accesso agli eventi del calendario.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IEventoRepository extends ChangeNotifier {
  /// Crea un nuovo evento nell'unità attiva.
  Future<void> creaEvento(Evento evento);

  /// Tutti gli eventi visibili, ordinati per data di inizio crescente.
  Future<List<Evento>> getEventi();

  /// Eventi che ricadono nel giorno [data] (inizio ≤ giorno ≤ fine).
  Future<List<Evento>> getEventiPerData(DateTime data);

  /// Eventi con data di inizio compresa tra [dal] e [al] (estremi inclusi).
  Future<List<Evento>> getEventiTraDate(DateTime dal, DateTime al);
}
