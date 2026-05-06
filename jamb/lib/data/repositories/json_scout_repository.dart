import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/scout.dart';
import '../../domain/repositories/scout_repository.dart';

class JsonScoutRepository extends IScoutRepository {
  static const String _assetPath = 'assets/data/scouts.json';
  static const String _storageKey = 'jamb_scouts_data_v3';
  
  SharedPreferences? _prefs;

  /// Inizializza SharedPreferences.
  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<List<Scout>> getRagazzi() async {
    await _init();
    try {
      String? jsonString = _prefs!.getString(_storageKey);
      
      // Se non c'è nulla in memoria locale, carica dagli asset
      if (jsonString == null) {
        jsonString = await rootBundle.loadString(_assetPath);
        // Salva subito in locale per future modifiche
        await _prefs!.setString(_storageKey, jsonString);
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => Scout.fromMap(e)).whereType<Scout>().toList();
    } catch (e) {
      debugPrint('Errore nel caricamento degli scout: $e');
      return [];
    }
  }

  @override
  Future<void> salvaRagazzo(Scout ragazzo) async {
    await _init();
    final ragazzi = await getRagazzi();
    
    // Trova l'indice del ragazzo da aggiornare o aggiungi se nuovo
    final index = ragazzi.indexWhere((s) => s.id == ragazzo.id);
    if (index != -1) {
      ragazzi[index] = ragazzo;
    } else {
      ragazzi.add(ragazzo);
    }

    // Serializza e salva in SharedPreferences
    final jsonList = ragazzi.map((s) => s.toMap()).toList();
    await _prefs!.setString(_storageKey, jsonEncode(jsonList));
    
    // Notifica i ViewModel in ascolto che i dati sono cambiati
    notifyListeners();
  }
}
