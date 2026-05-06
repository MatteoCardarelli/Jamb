import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';

/// ViewModel per la gestione dello stato della singola transazione.
/// Gestisce l'eliminazione della transazione tramite il repository.
class DettaglioTransazioneViewModel extends ChangeNotifier {
  final Transazione _transazione;
  final ITransazioneRepository _repository;

  DettaglioTransazioneViewModel(this._transazione, this._repository);

  Transazione get transazione => _transazione;

  String get tipoMovimento => _transazione.isUscita ? "USCITA" : "ENTRATA";
  
  Color get colorePrincipale => _transazione.isUscita 
      ? const Color(0xFFB91C1C) 
      : const Color(0xFF1B5E20);
      
  Color get coloreSfondo => _transazione.isUscita 
      ? const Color(0xFFFEF2F2) 
      : const Color(0xFFE8F5E9);

  /// Elimina la transazione corrente dal database
  Future<void> elimina() async {
    await _repository.eliminaTransazione(_transazione.id);
  }
}
