import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/veglia.dart';
import 'package:jamb/domain/repositories/veglia_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Elenco delle veglie del gruppo, filtrabile per branca.
class VeglieViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IVegliaRepository _repository;

  List<Veglia> _veglie = const [];
  BrancaVeglia? _filtro;

  VeglieViewModel(this._repository) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _veglie = await _repository.getVeglie();
      });

  /// Rilegge le veglie (es. dopo un errore).
  Future<void> ricarica() => _carica();

  /// Branca selezionata (`null` = tutte).
  BrancaVeglia? get filtro => _filtro;

  /// Veglie della branca selezionata.
  List<Veglia> get veglie =>
      _filtro == null ? _veglie : _veglie.where((v) => v.branca == _filtro).toList();

  /// Mostra solo le veglie di [branca] (`null` = tutte).
  void setFiltro(BrancaVeglia? branca) {
    _filtro = branca;
    notifyListeners();
  }

  /// Elimina [veglia]. Un errore viene propagato alla View.
  Future<void> elimina(Veglia veglia) => _repository.elimina(veglia.id);
}

/// Stato del form di una veglia, nuova o da modificare.
class FormVegliaViewModel extends ChangeNotifier {
  final IVegliaRepository _repository;
  final String _id;

  String titolo;
  BrancaVeglia branca;
  final List<MomentoVeglia> _momenti;

  FormVegliaViewModel(this._repository, {Veglia? esistente})
      : _id = esistente?.id ?? '',
        titolo = esistente?.titolo ?? '',
        branca = esistente?.branca ?? BrancaVeglia.rs,
        _momenti = List.of(esistente?.momenti ?? const []);

  bool get isModifica => _id.isNotEmpty;
  List<MomentoVeglia> get momenti => List.unmodifiable(_momenti);

  /// Una veglia ha bisogno di un titolo e di almeno un momento.
  bool get isValid => titolo.trim().isNotEmpty && _momenti.isNotEmpty;

  void setTitolo(String valore) {
    titolo = valore;
    notifyListeners();
  }

  void setBranca(BrancaVeglia valore) {
    branca = valore;
    notifyListeners();
  }

  void aggiungiMomento(TipoMomento tipo, String testo) {
    _momenti.add(MomentoVeglia(tipo: tipo, testo: testo.trim()));
    notifyListeners();
  }

  void rimuoviMomento(int indice) {
    _momenti.removeAt(indice);
    notifyListeners();
  }

  /// Sposta il momento [indice] di [passo] posizioni; fuori dai limiti non fa nulla.
  void spostaMomento(int indice, int passo) {
    final destinazione = indice + passo;
    if (destinazione < 0 || destinazione >= _momenti.length) return;
    _momenti.insert(destinazione, _momenti.removeAt(indice));
    notifyListeners();
  }

  /// Salva la veglia. Un errore viene propagato alla View.
  Future<void> salva() => _repository.salva(
        Veglia(id: _id, titolo: titolo, branca: branca, momenti: List.of(_momenti)),
      );
}
