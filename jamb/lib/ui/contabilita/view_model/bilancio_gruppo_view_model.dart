import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/anno_scout.dart';
import 'package:jamb/domain/entities/bilancio.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Bilancio consolidato del gruppo (US31): scelta dell'anno scout, totale e
/// bilancio di ogni cassa.
class BilancioGruppoViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final ITransazioneRepository _transazioni;
  final DateTime _oggi;

  List<CassaDelGruppo> _casse = const [];
  late String _annoScout = annoScoutDi(_oggi);

  /// [oggi] serve solo ai test.
  BilancioGruppoViewModel(this._transazioni, {DateTime? oggi}) : _oggi = oggi ?? DateTime.now() {
    _transazioni.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _transazioni.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _casse = await _transazioni.getCasseDelGruppo();
      });

  /// Rilegge le casse (es. dopo un errore).
  Future<void> ricarica() => _carica();

  /// Anno scout selezionato.
  String get annoScout => _annoScout;

  /// Anni scout selezionabili, dal più recente.
  List<String> get anni => anniDiBilancio(_casse.expand((c) => c.transazioni), _oggi);

  /// Consolidato dell'anno selezionato.
  BilancioGruppo get consolidato => BilancioGruppo.daCasse(_casse, _annoScout);

  /// Seleziona l'anno scout [anno].
  void scegliAnno(String anno) {
    if (anno == _annoScout) return;
    _annoScout = anno;
    notifyListeners();
  }
}
