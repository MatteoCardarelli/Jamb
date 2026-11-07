import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// ViewModel per la gestione dello stato della singola transazione.
/// Gestisce l'eliminazione della transazione tramite il repository e il
/// caricamento della foto dello scontrino, se c'è.
class DettaglioTransazioneViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final Transazione _transazione;
  final ITransazioneRepository _repository;
  String? _urlRicevuta;

  DettaglioTransazioneViewModel(this._transazione, this._repository) {
    if (haRicevuta) caricaRicevuta();
  }

  Transazione get transazione => _transazione;

  String get tipoMovimento => _transazione.isUscita ? "USCITA" : "ENTRATA";

  Color get colorePrincipale => _transazione.isUscita
      ? const Color(0xFFB91C1C)
      : const Color(0xFF1B5E20);

  Color get coloreSfondo => _transazione.isUscita
      ? const Color(0xFFFEF2F2)
      : const Color(0xFFE8F5E9);

  /// `true` se alla transazione è allegata una ricevuta.
  bool get haRicevuta => _transazione.percorsoRicevuta != null;

  /// `true` se la ricevuta è un PDF, che si apre fuori dall'app invece di
  /// essere mostrato come immagine.
  bool get ricevutaPdf =>
      _transazione.percorsoRicevuta?.toLowerCase().endsWith('.pdf') ?? false;

  /// URL temporaneo della ricevuta, quando è stato ottenuto.
  String? get urlRicevuta => _urlRicevuta;

  /// Chiede l'URL della ricevuta (anche per riprovare dopo un errore).
  Future<void> caricaRicevuta() => eseguiCaricamento(() async {
        _urlRicevuta = await _repository.urlRicevuta(_transazione.percorsoRicevuta!);
      });

  /// Elimina la transazione corrente dal database
  Future<void> elimina() async {
    await _repository.eliminaTransazione(_transazione.id);
  }
}
