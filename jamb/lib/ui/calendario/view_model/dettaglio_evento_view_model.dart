import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';

/// Stato del dettaglio di un evento: lo mostra, lo aggiorna dopo una modifica
/// e ne gestisce l'eliminazione tramite il repository.
class DettaglioEventoViewModel extends ChangeNotifier {
  final IEventoRepository _repository;
  Evento _evento;

  DettaglioEventoViewModel(this._evento, this._repository);

  Evento get evento => _evento;

  /// Quando si svolge l'evento, in forma leggibile.
  ///
  /// Esempi: "sab 7 nov 2026, 15:00 – 17:00", "sab 7 nov 2026 · Tutto il giorno",
  /// "sab 7 nov 2026 – dom 8 nov 2026 · Tutto il giorno".
  String get quando {
    final giorno = DateFormat('EEE d MMM y', 'it_IT');
    final ora = DateFormat('HH:mm');
    final inizio = _evento.dataInizio;
    final fine = _evento.dataFine;
    final stessoGiorno = DateUtils.isSameDay(inizio, fine);

    if (_evento.tuttoIlGiorno) {
      final giorni = stessoGiorno
          ? giorno.format(inizio)
          : '${giorno.format(inizio)} – ${giorno.format(fine)}';
      return '$giorni · Tutto il giorno';
    }
    return stessoGiorno
        ? '${giorno.format(inizio)}, ${ora.format(inizio)} – ${ora.format(fine)}'
        : '${giorno.format(inizio)}, ${ora.format(inizio)} – ${giorno.format(fine)}, ${ora.format(fine)}';
  }

  /// Mostra la versione dell'evento appena salvata dal form di modifica.
  void aggiornato(Evento evento) {
    _evento = evento;
    notifyListeners();
  }

  /// Elimina l'evento. Un errore viene propagato alla View.
  Future<void> elimina() => _repository.eliminaEvento(_evento.id);
}
