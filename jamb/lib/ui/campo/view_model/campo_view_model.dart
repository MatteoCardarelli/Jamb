import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/domain/repositories/campo_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Elenco dei campi e delle uscite dell'unità attiva.
class CampiViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final ICampoRepository _repository;

  /// Tipi proposti alla branca dell'unità attiva.
  final List<TipoCampo> tipi;

  List<Campo> _campi = const [];

  CampiViewModel(this._repository, {required this.tipi}) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _campi = await _repository.getCampi();
      });

  /// Rilegge i campi (es. dopo un errore).
  Future<void> ricarica() => _carica();

  List<Campo> get campi => _campi;

  /// Crea un campo e lo restituisce. Gli errori vengono propagati alla View.
  Future<Campo> crea(TipoCampo tipo, String titolo) => _repository.creaCampo(tipo, titolo);

  /// Elimina [campo] con tutto ciò che contiene.
  Future<void> elimina(Campo campo) => _repository.eliminaCampo(campo.id);
}

/// Organizzazione di un campo (US18): pattuglie, compiti e contatti.
class CampoViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final ICampoRepository _repository;
  final String _campoId;

  Campo? _campo;
  List<Pattuglia> _pattuglie = const [];
  List<CompitoCampo> _compiti = const [];
  List<MembroUnita> _staff = const [];
  List<ContattoCampo> _contatti = const [];

  CampoViewModel(this._repository, this._campoId) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        final pattuglie = await _repository.getPattuglie(_campoId);
        _compiti = await _repository.getCompiti(pattuglie.map((p) => p.id));
        _staff = await _repository.getStaff();
        _contatti = await _repository.getContatti(_campoId);
        _pattuglie = pattuglie;
        _campo = await _repository.getCampo(_campoId);
      });

  /// Rilegge i dati (es. dopo un errore).
  Future<void> ricarica() => _carica();

  /// Il campo (`null` se è stato eliminato nel frattempo).
  Campo? get campo => _campo;
  List<Pattuglia> get pattuglie => _pattuglie;
  List<ContattoCampo> get contatti => _contatti;

  /// Capi dell'unità tra cui scegliere i componenti.
  List<MembroUnita> get staff => _staff;

  /// Compiti di [pattuglia].
  List<CompitoCampo> compitiDi(Pattuglia pattuglia) =>
      _compiti.where((c) => c.pattugliaId == pattuglia.id).toList();

  /// Componenti di [pattuglia]: chi non è più nello staff non compare.
  List<MembroUnita> membriDi(Pattuglia pattuglia) =>
      _staff.where((m) => pattuglia.membri.contains(m.id)).toList();

  /// Avanzamento complessivo.
  AvanzamentoCampo get avanzamento => AvanzamentoCampo.di(_compiti);

  /// Avanzamento di [pattuglia].
  AvanzamentoCampo avanzamentoDi(Pattuglia pattuglia) =>
      AvanzamentoCampo.di(compitiDi(pattuglia));

  Campo _copia({String? titolo, String? luogo, DateTime? inizio, DateTime? fine}) {
    final c = _campo!;
    return Campo(
      id: c.id,
      tipo: c.tipo,
      annoScout: c.annoScout,
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

  Future<void> creaPattuglia(String nome) => _repository.creaPattuglia(_campoId, nome);
  Future<void> rinominaPattuglia(Pattuglia p, String nome) => _repository.rinominaPattuglia(p.id, nome);
  Future<void> eliminaPattuglia(Pattuglia p) => _repository.eliminaPattuglia(p.id);

  /// Sostituisce i componenti di [p].
  Future<void> salvaMembri(Pattuglia p, Set<String> membri) =>
      _repository.salvaMembriPattuglia(p.id, membri);

  Future<void> creaCompito(Pattuglia p, String titolo) => _repository.creaCompito(p.id, titolo);

  /// Porta [compito] allo stato successivo: da fare, in corso, fatto, e di nuovo.
  Future<void> avanzaStato(CompitoCampo compito) =>
      _repository.impostaStato(compito.id, compito.stato.prossimo);

  Future<void> eliminaCompito(CompitoCampo compito) => _repository.eliminaCompito(compito.id);

  Future<void> creaContatto(String etichetta, String telefono) =>
      _repository.creaContatto(_campoId, etichetta, telefono);

  Future<void> eliminaContatto(ContattoCampo contatto) => _repository.eliminaContatto(contatto.id);
}

/// Motivo per cui un nome o un titolo del campo non va bene, o `null`.
String? erroreTestoCampo(String testo) =>
    testo.trim().isEmpty ? 'Il testo non può essere vuoto.' : null;
