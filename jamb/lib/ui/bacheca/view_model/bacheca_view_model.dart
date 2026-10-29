import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamb/domain/entities/avviso.dart';
import 'package:jamb/domain/repositories/avviso_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Destinatari per cui filtrare la bacheca.
///
/// Il filtro è esatto: «Tutta l'unità» mostra solo gli avvisi per l'unità,
/// una squadriglia solo quelli indirizzati a lei.
class FiltroAvvisi {
  /// Squadriglia destinataria; `null` per [tutti] e [unita].
  final String? squadriglia;
  final bool _soloUnita;

  const FiltroAvvisi._(this.squadriglia, this._soloUnita);

  /// Nessun filtro.
  static const tutti = FiltroAvvisi._(null, false);

  /// Solo gli avvisi per tutta l'unità.
  static const unita = FiltroAvvisi._(null, true);

  /// Solo gli avvisi per la squadriglia [nome].
  const FiltroAvvisi.squadriglia(String nome) : this._(nome, false);

  /// Testo del filtro nella barra dei filtri.
  String get etichetta => squadriglia ?? (_soloUnita ? "Tutta l'unità" : 'Tutti');

  /// `true` se [avviso] va mostrato con questo filtro.
  bool include(Avviso avviso) {
    if (_soloUnita) return avviso.perTuttaLUnita;
    return squadriglia == null || avviso.squadriglia == squadriglia;
  }

  @override
  bool operator ==(Object other) =>
      other is FiltroAvvisi &&
      other.squadriglia == squadriglia &&
      other._soloUnita == _soloUnita;

  @override
  int get hashCode => Object.hash(squadriglia, _soloUnita);
}

/// Stato della bacheca avvisi dell'unità: elenco dal più recente, filtro per
/// destinatari e numero di avvisi non letti (mostrato sulla campanella).
///
/// È unico per tutta l'app e si ricarica quando il repository cambia, così
/// la campanella si aggiorna appena un avviso viene letto o pubblicato.
class BachecaViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IAvvisoRepository _repository;

  List<Avviso> _avvisi = [];
  FiltroAvvisi _filtro = FiltroAvvisi.tutti;

  BachecaViewModel(this._repository) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        final avvisi = await _repository.getAvvisi();
        avvisi.sort((a, b) => b.dataPubblicazione.compareTo(a.dataPubblicazione));
        _avvisi = avvisi;
        // Un filtro su una squadriglia senza più avvisi lascerebbe un elenco
        // vuoto senza il chip per toglierlo.
        if (!filtri.contains(_filtro)) _filtro = FiltroAvvisi.tutti;
      });

  /// Ricarica gli avvisi (es. dopo un errore o trascinando l'elenco).
  Future<void> ricarica() => _carica();

  /// Avvisi che rispettano il filtro attivo, dal più recente.
  List<Avviso> get avvisi => _avvisi.where(_filtro.include).toList();

  /// Avvisi non ancora letti dall'utente, su tutta la bacheca.
  int get nonLetti => _avvisi.where((a) => !a.letto).length;

  FiltroAvvisi get filtro => _filtro;

  /// Filtri disponibili: tutti, tutta l'unità e le squadriglie che hanno
  /// almeno un avviso, in ordine alfabetico.
  List<FiltroAvvisi> get filtri {
    final squadriglie = _avvisi.map((a) => a.squadriglia).whereType<String>().toSet().toList()
      ..sort();
    return [
      FiltroAvvisi.tutti,
      FiltroAvvisi.unita,
      ...squadriglie.map(FiltroAvvisi.squadriglia),
    ];
  }

  void setFiltro(FiltroAvvisi filtro) {
    _filtro = filtro;
    notifyListeners();
  }

  /// Data di pubblicazione breve per l'elenco: l'ora se è di oggi, altrimenti
  /// giorno e mese (con l'anno se diverso da quello corrente).
  static String dataBreve(DateTime data, {DateTime? adesso}) {
    final oggi = adesso ?? DateTime.now();
    if (DateUtils.isSameDay(data, oggi)) return DateFormat('HH:mm').format(data);
    final formato = data.year == oggi.year ? 'd MMM' : 'd MMM y';
    return DateFormat(formato, 'it_IT').format(data);
  }
}
