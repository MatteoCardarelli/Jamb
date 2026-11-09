import 'package:flutter/material.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato del calendario: eventi del giorno selezionato e prossimi eventi
/// (2 settimane), filtrati per livello. Legge gli eventi una sola volta e li
/// filtra in memoria: cambiare giorno non richiede nulla al server. Si
/// ricarica quando il repository degli eventi cambia.
class CalendarioViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IEventoRepository _eventoRepository;

  DateTime _selectedDate = DateTime.now();
  FiltroCalendario _filtro = FiltroCalendario.tutti;
  List<Evento> _tuttiEventi = [];

  CalendarioViewModel(this._eventoRepository) {
    _loadEventi();
    _eventoRepository.addListener(_loadEventi);
  }

  DateTime get selectedDate => _selectedDate;
  FiltroCalendario get filtro => _filtro;

  /// Filtri tra cui scegliere, comprese le altre unità con eventi.
  List<FiltroCalendario> get filtri => FiltroCalendario.disponibili(_tuttiEventi);

  Iterable<Evento> get _filtrati => _tuttiEventi.where(_filtro.include);

  List<Evento> get eventiDelGiorno => getEventiForDay(_selectedDate);
  List<Evento> get prossimiEventi => eventiProssimi(_filtrati, DateTime.now());

  /// Cambia il giorno selezionato.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Mostra solo gli eventi di [filtro].
  void setFiltro(FiltroCalendario filtro) {
    _filtro = filtro;
    notifyListeners();
  }

  Future<void> _loadEventi() => eseguiCaricamento(() async {
        _tuttiEventi = await _eventoRepository.getEventi();
        // Un'unità rimasta senza eventi lascerebbe un calendario vuoto senza
        // il chip per togliere il filtro.
        if (!filtri.contains(_filtro)) _filtro = FiltroCalendario.tutti;
      });

  /// Ricarica gli eventi (es. dopo un errore).
  Future<void> refresh() => _loadEventi();

  /// Eventi che ricadono nel giorno [day] (usato anche per i marker).
  List<Evento> getEventiForDay(DateTime day) =>
      _filtrati.where((e) => eventoNelGiorno(e, day)).toList();

  @override
  void dispose() {
    _eventoRepository.removeListener(_loadEventi);
    super.dispose();
  }
}
