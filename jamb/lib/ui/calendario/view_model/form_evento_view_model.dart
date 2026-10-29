import 'package:flutter/material.dart';
import 'package:jamb/core/categoria_evento_colori.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';
import '../../../domain/repositories/obiettivo_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato del form evento, usato sia per crearne uno nuovo sia per modificare
/// [eventoEsistente]: titolo, luogo, date, giornata intera e categorie.
/// Valida i dati e li salva tramite il repository.
class FormEventoViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IEventoRepository _eventoRepository;
  final IObiettivoRepository _obiettivoRepository;
  final Evento? _eventoEsistente;

  late String _titolo;
  late String _luogo;
  late DateTime _dataInizio;
  late DateTime _dataFine;
  late bool _tuttoIlGiorno;
  late final List<String> _categorieSelezionate;
  List<String> _categorieDisponibili = const [categoriaAltro];

  /// Un nuovo evento parte da [giorno] (es. quello selezionato nel calendario)
  /// all'ora attuale, e dura un'ora. [adesso] serve solo ai test.
  FormEventoViewModel(
    this._eventoRepository,
    this._obiettivoRepository, {
    Evento? eventoEsistente,
    DateTime? giorno,
    DateTime? adesso,
  }) : _eventoEsistente = eventoEsistente {
    final evento = eventoEsistente;
    if (evento != null) {
      _titolo = evento.titolo;
      _luogo = evento.luogo;
      _dataInizio = evento.dataInizio;
      _dataFine = evento.dataFine;
      _tuttoIlGiorno = evento.tuttoIlGiorno;
      _categorieSelezionate = List.of(evento.categorie);
    } else {
      final ora = adesso ?? DateTime.now();
      final g = giorno ?? ora;
      _titolo = '';
      _luogo = '';
      _dataInizio = DateTime(g.year, g.month, g.day, ora.hour, ora.minute);
      _dataFine = _dataInizio.add(const Duration(hours: 1));
      _tuttoIlGiorno = false;
      _categorieSelezionate = [];
    }
    _caricaCategorie();
  }

  /// `true` se il form modifica un evento esistente.
  bool get isModifica => _eventoEsistente != null;

  String get titolo => _titolo;
  String get luogo => _luogo;
  DateTime get dataInizio => _dataInizio;
  DateTime get dataFine => _dataFine;
  bool get tuttoIlGiorno => _tuttoIlGiorno;
  List<String> get categorieSelezionate => _categorieSelezionate;

  /// Categorie selezionabili: i domini degli obiettivi del Programma d'Unità,
  /// quelle già assegnate all'evento e la voce "Altro" sempre disponibile.
  List<String> get categorieDisponibili => _categorieDisponibili;

  /// Carica i domini degli obiettivi dell'unità e li usa come categorie.
  /// Se il caricamento fallisce restano "Altro" e le categorie già scelte.
  Future<void> _caricaCategorie() => eseguiCaricamento(() async {
    final obiettivi = await _obiettivoRepository.getObiettivi();
    final categorie = {
      ...obiettivi.map((o) => o.dominio.trim()),
      // Una categoria rinominata nel Programma resta visibile e deselezionabile.
      ..._categorieSelezionate,
    }.where((c) => c.isNotEmpty && c != categoriaAltro).toList()..sort();

    _categorieDisponibili = [...categorie, categoriaAltro];
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

  void setTuttoIlGiorno(bool value) {
    _tuttoIlGiorno = value;
    notifyListeners();
  }

  void setDataInizio(DateTime date) {
    _dataInizio = date;
    // Se la data di fine è precedente alla nuova data di inizio, la sposto in avanti
    if (_dataFine.isBefore(_dataInizio)) {
      _dataFine = _tuttoIlGiorno
          ? _dataInizio
          : _dataInizio.add(const Duration(hours: 1));
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

  /// Inizio salvato: per la giornata intera le 00:00 del primo giorno.
  DateTime get _inizioEffettivo => _tuttoIlGiorno
      ? DateTime(_dataInizio.year, _dataInizio.month, _dataInizio.day)
      : _dataInizio;

  /// Fine salvata: per la giornata intera le 23:59 dell'ultimo giorno.
  DateTime get _fineEffettiva => _tuttoIlGiorno
      ? DateTime(_dataFine.year, _dataFine.month, _dataFine.day, 23, 59)
      : _dataFine;

  bool get isValid {
    return _titolo.trim().isNotEmpty &&
        _luogo.trim().isNotEmpty &&
        _categorieSelezionate.isNotEmpty &&
        !_fineEffettiva.isBefore(_inizioEffettivo);
  }

  /// Crea o aggiorna l'evento e lo restituisce (`null` se il form non è valido).
  /// Un errore di salvataggio viene propagato alla View.
  Future<Evento?> salvaEvento() async {
    if (!isValid) return null;

    final evento = Evento(
      id:
          _eventoEsistente?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titolo: _titolo.trim(),
      dataInizio: _inizioEffettivo,
      dataFine: _fineEffettiva,
      luogo: _luogo.trim(),
      categorie: List.of(_categorieSelezionate),
      colorePrincipale: coloreCategoria(_categorieSelezionate.first),
      tuttoIlGiorno: _tuttoIlGiorno,
    );

    if (isModifica) {
      await _eventoRepository.aggiornaEvento(evento);
    } else {
      await _eventoRepository.creaEvento(evento);
    }
    return evento;
  }
}
