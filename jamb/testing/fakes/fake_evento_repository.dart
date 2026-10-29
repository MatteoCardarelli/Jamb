import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/domain/repositories/evento_repository.dart';

/// Repository degli eventi finto (in memoria) per i test dei ViewModel.
///
/// Registra gli eventi creati e aggiornati per verificare quale operazione
/// è stata chiamata.
class FakeEventoRepository extends ChangeNotifier implements IEventoRepository {
  final List<Evento> creati = [];
  final List<Evento> aggiornati = [];
  final List<String> eliminati = [];

  @override
  Future<void> creaEvento(Evento evento) async => creati.add(evento);

  @override
  Future<void> aggiornaEvento(Evento evento) async => aggiornati.add(evento);

  @override
  Future<void> eliminaEvento(String id) async => eliminati.add(id);

  @override
  Future<List<Evento>> getEventi() async => const [];

  @override
  Future<List<Evento>> getEventiPerData(DateTime data) async => const [];

  @override
  Future<List<Evento>> getEventiTraDate(DateTime dal, DateTime al) async => const [];
}
