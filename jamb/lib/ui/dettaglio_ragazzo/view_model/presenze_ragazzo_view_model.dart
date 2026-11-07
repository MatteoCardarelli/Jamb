import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/domain/repositories/presenza_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Storico delle presenze di un ragazzo nel suo dettaglio, con la
/// segnalazione delle assenze ripetute. Si ricarica quando un appello viene
/// salvato.
class PresenzeRagazzoViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  /// Presenze mostrate nel riquadro, dalla più recente.
  static const int ultimeMostrate = 5;

  final String ragazzoId;
  final IPresenzaRepository _repository;
  final DateTime? _adesso;

  List<PresenzaRagazzo> _storico = [];

  /// [adesso] serve solo ai test.
  PresenzeRagazzoViewModel(this.ragazzoId, this._repository, {DateTime? adesso})
      : _adesso = adesso {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _storico = await _repository.getStorico(ragazzoId);
      });

  /// Ricarica lo storico (es. dopo un errore).
  Future<void> ricarica() => _carica();

  DateTime get _ora => _adesso ?? DateTime.now();

  /// Ultime presenze registrate, dalla più recente.
  List<PresenzaRagazzo> get ultime => _storico.take(ultimeMostrate).toList();

  /// Assenze non giustificate consecutive più recenti.
  int get serieAssenze => assenzeConsecutive(_storico, adesso: _ora);

  /// `true` se il ragazzo va segnalato ai capi.
  bool get assenzeRipetute => serieAssenze >= sogliaAssenzeRipetute;

  /// Riepilogo degli eventi già iniziati, es. "Presente a 8 attività su 10".
  /// Vuoto se non c'è ancora nessun appello.
  String get riepilogo {
    final passate = _storico.where((p) => !p.dataEvento.isAfter(_ora)).toList();
    if (passate.isEmpty) return '';
    final presenti = passate.where((p) => p.stato == StatoPresenza.presente).length;
    return 'Presente a $presenti attività su ${passate.length}';
  }
}
