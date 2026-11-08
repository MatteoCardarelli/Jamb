import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/domain/repositories/evento_repository.dart';

/// Repository degli eventi finto (in memoria) per i test dei ViewModel.
///
/// Registra le scritture, con ripetizione e ambito, per verificare quale
/// operazione è stata chiamata.
class FakeEventoRepository extends ChangeNotifier implements IEventoRepository {
  /// Eventi restituiti da [getEventi].
  final List<Evento> eventi;
  final List<Evento> creati = [];
  final List<({Ripetizione ripetizione, DateTime? finoAl})> ripetizioni = [];
  final List<Evento> aggiornati = [];
  final List<AmbitoSerie> ambitiAggiornamento = [];
  final List<Evento> eliminati = [];
  final List<AmbitoSerie> ambitiEliminazione = [];

  FakeEventoRepository({List<Evento>? eventi}) : eventi = eventi ?? [];

  @override
  Future<void> creaEvento(
    Evento evento, {
    Ripetizione ripetizione = Ripetizione.mai,
    DateTime? finoAl,
  }) async {
    creati.add(evento);
    ripetizioni.add((ripetizione: ripetizione, finoAl: finoAl));
  }

  @override
  Future<void> aggiornaEvento(Evento evento, {AmbitoSerie ambito = AmbitoSerie.soloQuesto}) async {
    aggiornati.add(evento);
    ambitiAggiornamento.add(ambito);
  }

  @override
  Future<void> eliminaEvento(Evento evento, {AmbitoSerie ambito = AmbitoSerie.soloQuesto}) async {
    eliminati.add(evento);
    ambitiEliminazione.add(ambito);
  }

  @override
  Future<List<Evento>> getEventi() async => List.of(eventi);

  @override
  Future<List<Evento>> getEventiPerData(DateTime data) async => const [];

  @override
  Future<List<Evento>> getEventiTraDate(DateTime dal, DateTime al) async => const [];
}
