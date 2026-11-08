import 'package:flutter/material.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato del calendario: eventi del giorno selezionato e prossimi eventi
/// (2 settimane), filtrati per livello (unità, Co.Ca.). Si ricarica quando il
/// repository degli eventi cambia.
class CalendarioViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IEventoRepository _eventoRepository;

  DateTime _selectedDate = DateTime.now();
  FiltroCalendario _filtro = FiltroCalendario.tutti;
  List<Evento> _eventiDelGiorno = [];
  List<Evento> _tuttiEventi = [];
  List<Evento> _prossimiEventi = [];

  CalendarioViewModel(this._eventoRepository) {
    _loadEventi();
    _eventoRepository.addListener(_loadEventi);
  }

  DateTime get selectedDate => _selectedDate;
  FiltroCalendario get filtro => _filtro;
  List<Evento> get eventiDelGiorno => _eventiDelGiorno.where(_filtro.include).toList();
  List<Evento> get prossimiEventi => _prossimiEventi.where(_filtro.include).toList();

  /// Cambia il giorno selezionato e ricarica gli eventi correlati.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadEventi();
  }

  /// Mostra solo gli eventi di [filtro]; non serve rileggere i dati.
  void setFiltro(FiltroCalendario filtro) {
    _filtro = filtro;
    notifyListeners();
  }

  Future<void> _loadEventi() => eseguiCaricamento(() async {
        _eventiDelGiorno = await _eventoRepository.getEventiPerData(_selectedDate);
        _tuttiEventi = await _eventoRepository.getEventi();

        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final tomorrow = today.add(const Duration(days: 1));
        final inTwoWeeks = tomorrow.add(const Duration(days: 14));
        _prossimiEventi = await _eventoRepository.getEventiTraDate(tomorrow, inTwoWeeks);
      });

  /// Ricarica gli eventi (es. dopo un errore).
  Future<void> refresh() => _loadEventi();

  /// Eventi che ricadono nel giorno [day] (usato per i marker del calendario).
  List<Evento> getEventiForDay(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    return _tuttiEventi.where(_filtro.include).where((e) {
      final start = DateTime(e.dataInizio.year, e.dataInizio.month, e.dataInizio.day);
      final end = DateTime(e.dataFine.year, e.dataFine.month, e.dataFine.day);
      return (target.isAfter(start) || target.isAtSameMomentAs(start)) &&
             (target.isBefore(end) || target.isAtSameMomentAs(end));
    }).toList();
  }

  @override
  void dispose() {
    _eventoRepository.removeListener(_loadEventi);
    super.dispose();
  }
}
