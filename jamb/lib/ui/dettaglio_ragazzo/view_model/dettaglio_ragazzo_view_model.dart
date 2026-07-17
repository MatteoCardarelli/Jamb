import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/entities/progresso.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';

/// ViewModel per la gestione del dettaglio di un singolo scout.
/// Gestisce la logica di business: validazione dati, unicità specialità/brevetti e persistenza.
class DettaglioRagazzoViewModel extends ChangeNotifier {
  final IScoutRepository _repository;
  Scout _scout;
  
  DettaglioRagazzoViewModel({
    required Scout scout,
    required IScoutRepository repository,
  }) : _scout = scout, _repository = repository;

  Future<List<String>> getSquadriglie() => _repository.getSquadriglie();

  Scout get scout => _scout;

  /// Getter per calcolare dinamicamente se mostrare l'alert medico (allergie)
  bool get hasAlert => _scout.allergie != null && _scout.allergie!.trim().isNotEmpty;

  /// Aggiunge una nuova specialità controllando che non sia già presente.
  Future<bool> aggiungiSpecialita(Specialita nuova) async {
    // Verifica se la specialità esiste già
    if (_scout.progresso.specialita.any((s) => s.nome == nuova.nome)) {
      return false; // Duplicato trovato
    }

    final nuoveSpecialita = List<Specialita>.from(_scout.progresso.specialita)..add(nuova);
    await aggiornaDati(_scout.copyWith(
      progresso: _scout.progresso.copyWith(specialita: nuoveSpecialita),
    ));
    return true;
  }

  /// Aggiorna una specialità esistente.
  Future<void> modificaSpecialita(int index, Specialita aggiornata) async {
    final nuoveSpecialita = List<Specialita>.from(_scout.progresso.specialita);
    nuoveSpecialita[index] = aggiornata;
    await aggiornaDati(_scout.copyWith(
      progresso: _scout.progresso.copyWith(specialita: nuoveSpecialita),
    ));
  }

  /// Rimuove una specialità.
  Future<void> rimuoviSpecialita(int index) async {
    final nuoveSpecialita = List<Specialita>.from(_scout.progresso.specialita)..removeAt(index);
    await aggiornaDati(_scout.copyWith(
      progresso: _scout.progresso.copyWith(specialita: nuoveSpecialita),
    ));
  }

  /// Aggiunge un nuovo brevetto controllando che non sia già presente.
  Future<bool> aggiungiBrevetto(Brevetto nuovo) async {
    // Verifica se il brevetto esiste già
    if (_scout.progresso.brevetti.any((b) => b.nome == nuovo.nome)) {
      return false; // Duplicato trovato
    }

    final nuoviBrevetti = List<Brevetto>.from(_scout.progresso.brevetti)..add(nuovo);
    await aggiornaDati(_scout.copyWith(
      progresso: _scout.progresso.copyWith(brevetti: nuoviBrevetti),
    ));
    return true;
  }

  /// Aggiorna un brevetto esistente.
  Future<void> modificaBrevetto(int index, Brevetto aggiornato) async {
    final nuoviBrevetti = List<Brevetto>.from(_scout.progresso.brevetti);
    nuoviBrevetti[index] = aggiornato;
    await aggiornaDati(_scout.copyWith(
      progresso: _scout.progresso.copyWith(brevetti: nuoviBrevetti),
    ));
  }

  /// Rimuove un brevetto.
  Future<void> rimuoviBrevetto(int index) async {
    final nuoviBrevetti = List<Brevetto>.from(_scout.progresso.brevetti)..removeAt(index);
    await aggiornaDati(_scout.copyWith(
      progresso: _scout.progresso.copyWith(brevetti: nuoviBrevetti),
    ));
  }

  /// Calcola il progresso (da 0.0 a 1.0) verso un determinato brevetto.
  double progressoBrevetto(BrevettoNome nomeBrevetto) {
    final correlate = nomeBrevetto.specialitaCorrelate;
    final possedute = _scout.progresso.specialita
        .where((s) => s.isPosseduta && correlate.contains(s.nome))
        .length;
    
    return (possedute / 4).clamp(0.0, 1.0);
  }

  /// Aggiorna la tappa del Sentiero dello scout.
  Future<void> aggiornaSentiero(Tappa nuovaTappa) async {
    await aggiornaDati(_scout.copyWith(
      progresso: _scout.progresso.copyWith(tappaAttuale: nuovaTappa),
    ));
  }

  // --- AZIONI GENERALI ---

  /// Salva lo scout aggiornato tramite il repository.
  Future<void> aggiornaDati(Scout nuovoScout) async {
    _scout = nuovoScout;
    await _repository.salvaRagazzo(_scout);
    notifyListeners();
  }
}
