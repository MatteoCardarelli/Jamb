import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/peg.dart';
import 'package:jamb/domain/repositories/peg_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Progetto Educativo di Gruppo: consultazione con l'avanzamento (US11) e
/// scrittura da parte del Capo Gruppo (US30).
class PegViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IPegRepository _repository;

  Peg _peg = const Peg();
  List<AvanzamentoPeg> _avanzamenti = const [];

  PegViewModel(this._repository) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _peg = await _repository.getPeg();
        _avanzamenti = calcolaAvanzamentoPeg(
          await _repository.getObiettivi(),
          await _repository.getGradiCollegati(),
        );
      });

  /// Rilegge i dati (es. dopo un errore).
  Future<void> ricarica() => _carica();

  Peg get peg => _peg;
  List<AvanzamentoPeg> get avanzamenti => _avanzamenti;

  /// Numero di punti critici.
  int get critici => _avanzamenti.where((a) => a.critico).length;

  /// Cambia il titolo mantenendo la premessa.
  Future<void> salvaTitolo(String titolo) =>
      _repository.salvaPeg(Peg(titolo: titolo, premessa: _peg.premessa));

  /// Cambia la premessa mantenendo il titolo.
  Future<void> salvaPremessa(String premessa) =>
      _repository.salvaPeg(Peg(titolo: _peg.titolo, premessa: premessa));

  /// Aggiunge un obiettivo. Gli errori vengono propagati alla View.
  Future<void> creaObiettivo(String titolo) => _repository.creaObiettivo(titolo, '');

  /// Cambia il titolo di [o].
  Future<void> rinominaObiettivo(PegObiettivo o, String titolo) => _repository.aggiornaObiettivo(
        PegObiettivo(id: o.id, titolo: titolo, descrizione: o.descrizione),
      );

  /// Cambia la descrizione di [o].
  Future<void> descriviObiettivo(PegObiettivo o, String descrizione) =>
      _repository.aggiornaObiettivo(
        PegObiettivo(id: o.id, titolo: o.titolo, descrizione: descrizione),
      );

  /// Elimina [o].
  Future<void> eliminaObiettivo(PegObiettivo o) => _repository.eliminaObiettivo(o.id);
}

/// Motivo per cui il titolo di un obiettivo non va bene, o `null`.
String? erroreTitoloPeg(String titolo) =>
    titolo.trim().isEmpty ? 'Il titolo non può essere vuoto.' : null;
