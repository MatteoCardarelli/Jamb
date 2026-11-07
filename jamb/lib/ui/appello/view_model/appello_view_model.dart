import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/repositories/presenza_repository.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato dell'appello di un [evento]: i ragazzi dell'unità divisi per
/// squadriglia, lo stato segnato per ciascuno e il salvataggio delle sole
/// modifiche in un'unica scrittura.
class AppelloViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  /// Etichetta del gruppo dei ragazzi senza squadriglia.
  static const senzaSquadriglia = 'Senza squadriglia';

  final Evento evento;
  final IScoutRepository _scoutRepository;
  final IPresenzaRepository _presenzaRepository;

  List<Scout> _ragazzi = [];
  Map<String, StatoPresenza> _salvati = {};
  Map<String, StatoPresenza> _stati = {};

  AppelloViewModel(this.evento, this._scoutRepository, this._presenzaRepository) {
    _carica();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        final ragazzi = await _scoutRepository.getRagazzi();
        final appello = await _presenzaRepository.getAppello(evento.id);
        _ragazzi = ragazzi;
        _salvati = appello;
        _stati = Map.of(appello);
      });

  /// Ricarica ragazzi e appello (es. dopo un errore).
  Future<void> ricarica() => _carica();

  /// Ragazzi per squadriglia, in ordine alfabetico di squadriglia e di nome;
  /// chi non ha squadriglia è in fondo.
  Map<String, List<Scout>> get perSquadriglia {
    final gruppi = <String, List<Scout>>{};
    for (final r in _ragazzi) {
      final nome = r.squadriglia.trim().isEmpty ? senzaSquadriglia : r.squadriglia;
      gruppi.putIfAbsent(nome, () => []).add(r);
    }
    final nomi = gruppi.keys.toList()
      ..sort((a, b) {
        if (a == senzaSquadriglia) return 1;
        if (b == senzaSquadriglia) return -1;
        return a.compareTo(b);
      });
    return {
      for (final n in nomi) n: gruppi[n]!..sort((a, b) => a.nome.compareTo(b.nome)),
    };
  }

  /// Stato segnato per il ragazzo [id] (`null` se ancora da segnare).
  StatoPresenza? statoDi(String id) => _stati[id];

  void imposta(String id, StatoPresenza stato) {
    _stati[id] = stato;
    notifyListeners();
  }

  /// Segna presenti tutti i ragazzi ancora da segnare, senza toccare chi è
  /// già segnato assente o giustificato.
  void tuttiPresenti() {
    for (final r in _ragazzi) {
      _stati.putIfAbsent(r.id, () => StatoPresenza.presente);
    }
    notifyListeners();
  }

  /// Ragazzi dell'unità con lo [stato] indicato.
  int conta(StatoPresenza stato) => _ragazzi.where((r) => _stati[r.id] == stato).length;

  /// Ragazzi dell'unità ancora senza stato.
  int get daSegnare => _ragazzi.where((r) => !_stati.containsKey(r.id)).length;

  /// Riepilogo dell'appello, es. "12 presenti · 1 assente · 0 giustificati · 2 da segnare".
  String get riepilogo {
    String voce(int n, String singolare, String plurale) => '$n ${n == 1 ? singolare : plurale}';
    return [
      voce(conta(StatoPresenza.presente), 'presente', 'presenti'),
      voce(conta(StatoPresenza.assente), 'assente', 'assenti'),
      voce(conta(StatoPresenza.giustificato), 'giustificato', 'giustificati'),
      '$daSegnare da segnare',
    ].join(' · ');
  }

  /// Stati cambiati rispetto all'ultimo salvataggio.
  Map<String, StatoPresenza> get _modifiche => {
        for (final voce in _stati.entries)
          if (_salvati[voce.key] != voce.value) voce.key: voce.value,
      };

  /// `true` se ci sono stati segnati e non ancora salvati.
  bool get modificato => _modifiche.isNotEmpty;

  /// Salva le modifiche in un'unica scrittura. Un errore viene propagato
  /// alla View e le modifiche restano da salvare.
  Future<void> salva() async {
    final modifiche = _modifiche;
    if (modifiche.isEmpty) return;
    await _presenzaRepository.salvaAppello(evento.id, modifiche);
    _salvati = Map.of(_stati);
    notifyListeners();
  }
}
