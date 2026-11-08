import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/repositories/campo_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Programmazione del campo dell'unità attiva (US18).
class CampoViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final ICampoRepository _repository;

  Campo? _campo;
  List<Pattuglia> _pattuglie = const [];
  List<CompitoCampo> _compiti = const [];

  CampoViewModel(this._repository) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        final campo = await _repository.getCampo();
        final pattuglie = campo == null
            ? const <Pattuglia>[]
            : await _repository.getPattuglie(campo.id);
        _compiti = await _repository.getCompiti(pattuglie.map((p) => p.id));
        _pattuglie = pattuglie;
        _campo = campo;
      });

  /// Rilegge i dati (es. dopo un errore).
  Future<void> ricarica() => _carica();

  /// Campo dell'anno in corso (`null` se non c'è ancora).
  Campo? get campo => _campo;
  List<Pattuglia> get pattuglie => _pattuglie;

  /// Compiti di [pattuglia].
  List<CompitoCampo> compitiDi(Pattuglia pattuglia) =>
      _compiti.where((c) => c.pattugliaId == pattuglia.id).toList();

  /// Avanzamento complessivo.
  AvanzamentoCampo get avanzamento => AvanzamentoCampo.di(_compiti);

  /// Avanzamento di [pattuglia].
  AvanzamentoCampo avanzamentoDi(Pattuglia pattuglia) =>
      AvanzamentoCampo.di(compitiDi(pattuglia));

  /// Crea il campo. Gli errori vengono propagati alla View.
  Future<void> creaCampo(String titolo) => _repository.creaCampo(titolo);

  Campo _copia({String? titolo, String? luogo, DateTime? inizio, DateTime? fine}) {
    final c = _campo!;
    return Campo(
      id: c.id,
      titolo: titolo ?? c.titolo,
      luogo: luogo ?? c.luogo,
      dataInizio: inizio ?? c.dataInizio,
      dataFine: fine ?? c.dataFine,
    );
  }

  Future<void> rinominaCampo(String titolo) => _repository.aggiornaCampo(_copia(titolo: titolo));
  Future<void> impostaLuogo(String luogo) => _repository.aggiornaCampo(_copia(luogo: luogo));
  Future<void> impostaDate(DateTime inizio, DateTime fine) =>
      _repository.aggiornaCampo(_copia(inizio: inizio, fine: fine));

  Future<void> creaPattuglia(String nome) => _repository.creaPattuglia(_campo!.id, nome);
  Future<void> rinominaPattuglia(Pattuglia p, String nome) => _repository.rinominaPattuglia(p.id, nome);
  Future<void> eliminaPattuglia(Pattuglia p) => _repository.eliminaPattuglia(p.id);

  Future<void> creaCompito(Pattuglia p, String titolo) => _repository.creaCompito(p.id, titolo);

  /// Porta [compito] allo stato successivo: da fare, in corso, fatto, e di nuovo.
  Future<void> avanzaStato(CompitoCampo compito) =>
      _repository.impostaStato(compito.id, compito.stato.prossimo);

  Future<void> eliminaCompito(CompitoCampo compito) => _repository.eliminaCompito(compito.id);
}

/// Motivo per cui un nome o un titolo del campo non va bene, o `null`.
String? erroreTestoCampo(String testo) =>
    testo.trim().isEmpty ? 'Il testo non può essere vuoto.' : null;
