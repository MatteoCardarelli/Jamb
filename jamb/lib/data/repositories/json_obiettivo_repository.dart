import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/obiettivo.dart';
import '../../domain/repositories/obiettivo_repository.dart';

class JsonObiettivoRepository implements IObiettivoRepository {
  static const String _assetPath = 'assets/data/obiettivi.json';
  static const String _storageKey = 'jamb_obiettivi_data';
  
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<List<Obiettivo>> getObiettivi() async {
    await _init();
    String? jsonString = _prefs!.getString(_storageKey);
    
    if (jsonString == null) {
      jsonString = await rootBundle.loadString(_assetPath);
      await _prefs!.setString(_storageKey, jsonString);
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Obiettivo.fromMap(e)).toList();
  }

  @override
  Future<void> salvaObiettivo(Obiettivo obiettivo) async {
    await _init();
    final obiettivi = await getObiettivi();
    
    final index = obiettivi.indexWhere((o) => o.id == obiettivo.id);
    if (index != -1) {
      obiettivi[index] = obiettivo;
    } else {
      obiettivi.add(obiettivo);
    }

    final jsonList = obiettivi.map((o) => o.toMap()).toList();
    await _prefs!.setString(_storageKey, jsonEncode(jsonList));
  }
}
