import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/badge.dart';
import 'package:jamb/domain/entities/formazione.dart';
import 'package:jamb/domain/repositories/formazione_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Profilo del capo connesso: iter formativo (US6) e Progetto del Capo (US7).
class ProfiloViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IFormazioneRepository _repository;

  List<TappaCompiuta> _tappe = const [];
  ProgettoCapo _progetto = const ProgettoCapo();
  List<BadgeJamb> _badge = const [];

  ProfiloViewModel(this._repository) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _tappe = await _repository.getMieTappe();
        _progetto = await _repository.getMioProgetto();
        _badge = badgeDaStorico(await _repository.getMioStorico());
      });

  /// Rilegge i dati (es. dopo un errore).
  Future<void> ricarica() => _carica();

  List<TappaCompiuta> get tappe => _tappe;
  ProgettoCapo get progetto => _progetto;

  /// Badge ricavati dallo storico associativo (US2).
  List<BadgeJamb> get badge => _badge;

  /// Segna [tappa] come compiuta il giorno [data], o ne corregge la data.
  Future<void> compiTappa(TappaFormativa tappa, DateTime data) =>
      _repository.salvaTappa(TappaCompiuta(tappa: tappa, data: data));

  /// Toglie [tappa] da quelle compiute.
  Future<void> rimuoviTappa(TappaFormativa tappa) => _repository.rimuoviTappa(tappa);

  /// Sostituisce il testo del Progetto.
  Future<void> salvaTesto(String testo) =>
      _repository.salvaMioProgetto(_progetto.copyWith(testo: testo));

  /// Aggiunge un passo in fondo al Progetto.
  Future<void> aggiungiPasso(String titolo) => _repository.salvaMioProgetto(
        _progetto.copyWith(passi: [..._progetto.passi, PassoProgetto(titolo: titolo)]),
      );

  /// Inverte lo stato del passo in posizione [indice].
  Future<void> invertiPasso(int indice) {
    final passi = List.of(_progetto.passi);
    passi[indice] = passi[indice].copyWith(fatto: !passi[indice].fatto);
    return _repository.salvaMioProgetto(_progetto.copyWith(passi: passi));
  }

  /// Elimina il passo in posizione [indice].
  Future<void> rimuoviPasso(int indice) {
    final passi = List.of(_progetto.passi)..removeAt(indice);
    return _repository.salvaMioProgetto(_progetto.copyWith(passi: passi));
  }
}

/// Formazione di tutta la Co.Ca. (US29), per il Capo Gruppo.
class FormazioneCocaViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IFormazioneRepository _repository;

  List<CapoFormazione> _capi = const [];

  FormazioneCocaViewModel(this._repository) {
    _carica();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _capi = ordinaPerIter(await _repository.getCapiDelGruppo());
      });

  /// Rilegge i dati (es. dopo un errore).
  Future<void> ricarica() => _carica();

  /// Capi del gruppo, prima chi è più indietro nell'iter.
  List<CapoFormazione> get capi => _capi;

  /// Progetto del Capo di [capo].
  Future<ProgettoCapo> progettoDi(CapoFormazione capo) => _repository.getProgettoDi(capo.id);
}
