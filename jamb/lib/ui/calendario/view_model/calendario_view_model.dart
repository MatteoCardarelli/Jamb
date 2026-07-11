import 'package:flutter/material.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';

class CalendarioViewModel extends ChangeNotifier {
  final IEventoRepository _eventoRepository;

  DateTime _selectedDate = DateTime.now();
  List<Evento> _eventiDelGiorno = [];
  List<Evento> _tuttiEventi = [];
  List<Evento> _prossimiEventi = [];

  CalendarioViewModel(this._eventoRepository) {
    _loadEventi();
    _eventoRepository.addListener(_loadEventi);
  }

  DateTime get selectedDate => _selectedDate;
  List<Evento> get eventiDelGiorno => _eventiDelGiorno;
  List<Evento> get prossimiEventi => _prossimiEventi;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadEventi();
  }

  Future<void> _loadEventi() async {
    _eventiDelGiorno = await _eventoRepository.getEventiPerData(_selectedDate);
    _tuttiEventi = await _eventoRepository.getEventi();
    
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final tomorrow = today.add(const Duration(days: 1));
    final inTwoWeeks = tomorrow.add(const Duration(days: 14));
    _prossimiEventi = await _eventoRepository.getEventiTraDate(tomorrow, inTwoWeeks);
    
    notifyListeners();
  }

  List<Evento> getEventiForDay(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    return _tuttiEventi.where((e) {
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
