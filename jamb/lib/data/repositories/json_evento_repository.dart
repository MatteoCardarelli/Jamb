import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/evento.dart';
import '../../domain/repositories/evento_repository.dart';

class JsonEventoRepository extends IEventoRepository {
  List<Evento> _eventi = [];
  bool _isLoaded = false;
  static const String _storageKey = 'jamb_eventi_data_v1';
  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadData() async {
    if (_isLoaded) return;
    await _initPrefs();
    
    try {
      String? storedData = _prefs!.getString(_storageKey);
      
      if (storedData == null) {
        // Carica e converte il mock iniziale
        final String response = await rootBundle.loadString('assets/data/eventi.json');
        final data = await json.decode(response) as List<dynamic>;
        
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        _eventi = data.map((json) {
          final offset = json['giorniOffset'] as int;
          final targetDate = today.add(Duration(days: offset));
          
          final timeInizio = (json['orarioInizio'] as String).split(':');
          final timeFine = (json['orarioFine'] as String).split(':');
          
          final dataInizio = targetDate.add(Duration(
            hours: int.parse(timeInizio[0]),
            minutes: int.parse(timeInizio[1]),
          ));
          
          final dataFine = targetDate.add(Duration(
            hours: int.parse(timeFine[0]),
            minutes: int.parse(timeFine[1]),
          ));
          
          return Evento(
            id: json['id'],
            titolo: json['titolo'],
            dataInizio: dataInizio,
            dataFine: dataFine,
            luogo: json['luogo'],
            categorie: (json['categorie'] as List).map((e) => CategoriaEvento.fromString(e)).toList(),
            colorePrincipale: Color(json['colorePrincipale']),
          );
        }).toList();
        
        // Salva la versione convertita per renderla persistente
        final jsonList = _eventi.map((e) => e.toMap()).toList();
        await _prefs!.setString(_storageKey, jsonEncode(jsonList));
      } else {
        // Carica i dati salvati
        final List<dynamic> jsonList = jsonDecode(storedData);
        _eventi = jsonList.map((j) => Evento.fromMap(j)).toList();
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Errore nel caricamento eventi: $e");
    }
  }

  Future<void> _saveData() async {
    await _initPrefs();
    final jsonList = _eventi.map((e) => e.toMap()).toList();
    await _prefs!.setString(_storageKey, jsonEncode(jsonList));
    notifyListeners();
  }

  @override
  Future<void> creaEvento(Evento evento) async {
    await _loadData();
    _eventi.add(evento);
    await _saveData();
  }

  @override
  Future<List<Evento>> getEventi() async {
    await _loadData();
    return _eventi;
  }

  @override
  Future<List<Evento>> getEventiPerData(DateTime data) async {
    await _loadData();
    final target = DateTime(data.year, data.month, data.day);
    return _eventi.where((e) {
      final start = DateTime(e.dataInizio.year, e.dataInizio.month, e.dataInizio.day);
      final end = DateTime(e.dataFine.year, e.dataFine.month, e.dataFine.day);
      return (target.isAfter(start) || target.isAtSameMomentAs(start)) &&
             (target.isBefore(end) || target.isAtSameMomentAs(end));
    }).toList();
  }

  @override
  Future<List<Evento>> getEventiTraDate(DateTime dal, DateTime al) async {
    await _loadData();
    return _eventi.where((e) => 
      (e.dataInizio.isAfter(dal) || e.dataInizio.isAtSameMomentAs(dal)) && 
      (e.dataInizio.isBefore(al) || e.dataInizio.isAtSameMomentAs(al))
    ).toList();
  }
}
