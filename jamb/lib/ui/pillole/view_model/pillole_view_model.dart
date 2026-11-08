import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/pillola.dart';
import 'package:jamb/domain/repositories/pillola_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Pillole del metodo: quella del giorno per la Home e l'elenco da gestire.
class PilloleViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IPillolaRepository _repository;
  final DateTime Function() _oggi;

  List<Pillola> _pillole = const [];
  List<Pillola> _spunti = const [];

  /// [oggi] serve solo ai test.
  PilloleViewModel(this._repository, {DateTime Function()? oggi})
      : _oggi = oggi ?? DateTime.now {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _pillole = await _repository.getPillole();
        _spunti = await _repository.getPillole(tipo: TipoPillola.spiritualita);
      });

  /// Rilegge le pillole (es. dopo un errore).
  Future<void> ricarica() => _carica();

  /// Tutte le pillole del metodo della branca.
  List<Pillola> get pillole => _pillole;

  /// Pillole di [tipo].
  List<Pillola> pilloleDi(TipoPillola tipo) =>
      tipo == TipoPillola.metodo ? _pillole : _spunti;

  /// Pillola del metodo di oggi (`null` se la branca non ne ha).
  Pillola? get delGiorno => pillolaDelGiorno(_pillole, _oggi());

  /// Aggiunge una pillola. Gli errori vengono propagati alla View.
  Future<void> crea(String testo, {TipoPillola tipo = TipoPillola.metodo}) =>
      _repository.crea(testo, tipo: tipo);

  /// Cambia il testo di [pillola].
  Future<void> aggiorna(Pillola pillola, String testo) =>
      _repository.aggiorna(pillola.id, testo);

  /// Elimina [pillola].
  Future<void> elimina(Pillola pillola) => _repository.elimina(pillola.id);
}
