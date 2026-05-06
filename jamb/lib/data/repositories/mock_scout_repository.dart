import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/scout.dart';
import '../../domain/repositories/scout_repository.dart';

class MockScoutRepository implements IScoutRepository {
  
  @override
  Future<List<Scout>> getRagazzi() async {
    // 1. Carichiamo il file JSON come stringa di testo
    final String response = await rootBundle.loadString('assets/data/scouts.json');
    
    // 2. Decodifichiamo la stringa in una lista di mappe (JSON -> Map)
    final List<dynamic> data = json.decode(response);
    
    // 3. Trasformiamo ogni mappa in un oggetto Scout usando il metodo fromMap che abbiamo scritto
    return data.map((map) => Scout.fromMap(map)).toList();
  }

  @override
  Future<void> salvaRagazzo(Scout ragazzo) async {
    // Essendo un file negli assets (sola lettura), non possiamo scriverci sopra.
    // Per ora simuliamo solo un ritardo per far finta di salvare su un server.
    print("Salvataggio di ${ragazzo.nome} in corso...");
    await Future.delayed(const Duration(seconds: 1));
    print("Salvataggio completato!");
  }
}
