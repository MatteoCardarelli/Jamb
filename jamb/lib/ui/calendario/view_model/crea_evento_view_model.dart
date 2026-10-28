import 'package:flutter/material.dart';
import 'package:jamb/core/categoria_evento_colori.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';
import '../../../domain/repositories/obiettivo_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato del form di creazione evento: titolo, luogo, date e categorie;
/// valida i dati e crea l'evento tramite il repository.
class CreaEventoViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IEventoRepository _eventoRepository;
  final IObiettivoRepository _obiettivoRepository;

  String _titolo = '';
  String _luogo = '';
  DateTime _dataInizio = DateTime.now();
  DateTime _dataFine = DateTime.now().add(const Duration(hours: 1));
  final List<String> _categorieSelezionate = [];
  List<String> _categorieDisponibili = const [categoriaAltro];

  CreaEventoViewModel(this._eventoRepository, this._obiettivoRepository) {
    _caricaCategorie();
  }

  String get titolo => _titolo;
  String get luogo => _luogo;
  DateTime get dataInizio => _dataInizio;
  DateTime get dataFine => _dataFine;
  List<String> get categorieSelezionate => _categorieSelezionate;

  /// Categorie selezionabili: i domini degli obiettivi del Programma d'Unità,
  /// più la voce "Altro" sempre disponibile.
  List<String> get categorieDisponibili => _categorieDisponibili;

  /// Carica i domini degli obiettivi dell'unità e li usa come categorie.
  /// Se il caricamento fallisce resta disponibile solo "Altro".
  Future<void> _caricaCategorie() => eseguiCaricamento(() async {
        final obiettivi = await _obiettivoRepository.getObiettivi();
        final domini = obiettivi
            .map((o) => o.dominio.trim())
            .where((d) => d.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        _categorieDisponibili = [...domini, categoriaAltro];
      });

  /// Riprova a caricare le categorie (es. dopo un errore).
  Future<void> ricaricaCategorie() => _caricaCategorie();

  void setTitolo(String value) {
    _titolo = value;
    notifyListeners();
  }

  void setLuogo(String value) {
    _luogo = value;
    notifyListeners();
  }

  void setDataInizio(DateTime date) {
    _dataInizio = date;
    // Se la data di fine è precedente alla nuova data di inizio, la sposto in avanti
    if (_dataFine.isBefore(_dataInizio)) {
      _dataFine = _dataInizio.add(const Duration(hours: 1));
    }
    notifyListeners();
  }

  void setDataFine(DateTime date) {
    _dataFine = date;
    notifyListeners();
  }

  /// Aggiunge o rimuove una categoria dalla selezione.
  void toggleCategoria(String categoria) {
    if (_categorieSelezionate.contains(categoria)) {
      _categorieSelezionate.remove(categoria);
    } else {
      _categorieSelezionate.add(categoria);
    }
    notifyListeners();
  }

  bool get isValid {
    return _titolo.trim().isNotEmpty &&
        _luogo.trim().isNotEmpty &&
        _categorieSelezionate.isNotEmpty &&
        (_dataFine.isAfter(_dataInizio) || _dataFine.isAtSameMomentAs(_dataInizio));
  }

  Future<void> salvaEvento() async {
    if (!isValid) return;

    final nuovoEvento = Evento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titolo: _titolo.trim(),
      dataInizio: _dataInizio,
      dataFine: _dataFine,
      luogo: _luogo.trim(),
      categorie: List.from(_categorieSelezionate),
      colorePrincipale: coloreCategoria(_categorieSelezionate.first),
    );

    await _eventoRepository.creaEvento(nuovoEvento);
  }
}
