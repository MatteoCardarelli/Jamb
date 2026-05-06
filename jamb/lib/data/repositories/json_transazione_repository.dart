import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/transazione.dart';
import '../../domain/repositories/transazione_repository.dart';

class JsonTransazioneRepository extends ITransazioneRepository {
  static const String _assetPath = 'assets/data/transazioni.json';
  static const String _storageKey = 'jamb_transactions_data_v1';
  
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<List<Transazione>> getTransazioni() async {
    await _init();
    String? storedData = _prefs!.getString(_storageKey);
    
    String jsonString;
    if (storedData == null) {
      jsonString = await rootBundle.loadString(_assetPath);
      await _prefs!.setString(_storageKey, jsonString);
    } else {
      jsonString = storedData;
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Transazione.fromMap(json)).toList();
  }

  @override
  Future<void> salvaTransazione(Transazione transazione) async {
    await _init();
    final transazioni = await getTransazioni();
    
    final index = transazioni.indexWhere((t) => t.id == transazione.id);
    if (index != -1) {
      transazioni[index] = transazione;
    } else {
      transazioni.add(transazione);
    }

    final jsonList = transazioni.map((t) => t.toMap()).toList();
    await _prefs!.setString(_storageKey, jsonEncode(jsonList));
    notifyListeners();
  }

  @override
  Future<void> eliminaTransazione(String id) async {
    await _init();
    final transazioni = await getTransazioni();
    transazioni.removeWhere((t) => t.id == id);
    
    final jsonList = transazioni.map((t) => t.toMap()).toList();
    await _prefs!.setString(_storageKey, jsonEncode(jsonList));
    notifyListeners();
  }
}
