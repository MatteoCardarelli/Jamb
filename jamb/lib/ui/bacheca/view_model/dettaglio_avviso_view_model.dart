import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:jamb/domain/entities/avviso.dart';
import 'package:jamb/domain/repositories/avviso_repository.dart';

/// Stato del dettaglio di un avviso: lo segna come letto all'apertura, lo
/// aggiorna dopo una modifica e ne gestisce l'eliminazione.
class DettaglioAvvisoViewModel extends ChangeNotifier {
  final IAvvisoRepository _repository;
  Avviso _avviso;

  DettaglioAvvisoViewModel(this._avviso, this._repository) {
    if (!_avviso.letto) _segnaComeLetto();
  }

  Avviso get avviso => _avviso;

  /// Destinatari in forma leggibile.
  String get destinatari => _avviso.squadriglia ?? "Tutta l'unità";

  /// Data e ora di pubblicazione, es. "gio 29 ott 2026, 15:30".
  String get pubblicato =>
      DateFormat("EEE d MMM y', 'HH:mm", 'it_IT').format(_avviso.dataPubblicazione);

  /// La lettura non è un'azione dell'utente: se non si registra, l'avviso
  /// resta tra i non letti e verrà segnato alla prossima apertura.
  Future<void> _segnaComeLetto() async {
    try {
      await _repository.segnaComeLetto(_avviso.id);
    } catch (e) {
      debugPrint('Lettura dell\'avviso non registrata: $e');
    }
  }

  /// Mostra la versione dell'avviso appena salvata dal form di modifica.
  void aggiornato(Avviso avviso) {
    _avviso = avviso;
    notifyListeners();
  }

  /// Elimina l'avviso. Un errore viene propagato alla View.
  Future<void> elimina() => _repository.eliminaAvviso(_avviso.id);
}
