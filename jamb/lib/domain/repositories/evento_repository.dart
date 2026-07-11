import 'package:flutter/foundation.dart';
import '../../domain/entities/evento.dart';

/// Interfaccia per il Repository degli Eventi.
/// Estende ChangeNotifier per permettere ai ViewModel di ascoltare i cambiamenti.
abstract class IEventoRepository extends ChangeNotifier {
  Future<void> creaEvento(Evento evento);
  Future<List<Evento>> getEventi();
  Future<List<Evento>> getEventiPerData(DateTime data);
  Future<List<Evento>> getEventiTraDate(DateTime dal, DateTime al);
}
