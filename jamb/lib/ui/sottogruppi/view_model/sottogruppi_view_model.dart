import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/sottogruppo_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato della gestione dei sottogruppi dell'unità attiva (US20).
class SottogruppiViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final ISottogruppoRepository _repository;

  /// Quali sottogruppi ha la branca dell'unità attiva.
  final SottogruppiBranca branca;

  List<Squadriglia> _squadriglie = const [];
  List<MembroUnita> _membri = const [];
  List<Sottogruppo> _sottogruppi = const [];

  SottogruppiViewModel(this._repository, this.branca) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _squadriglie = await _repository.getSquadriglie();
        _membri = await _repository.getMembriUnita();
        _sottogruppi = await _repository.getSottogruppi();
      });

  /// Rilegge i dati (es. dopo un errore).
  Future<void> ricarica() => _carica();

  List<Squadriglia> get attive => _squadriglie.where((s) => s.attiva).toList();
  List<Squadriglia> get disattivate => _squadriglie.where((s) => !s.attiva).toList();

  /// Ragazzi di [squadriglia].
  List<MembroUnita> membriDella(Squadriglia squadriglia) => membriDi(squadriglia, _membri);

  /// Consiglio Capi, calcolato dalle memberships attive.
  List<MembroUnita> get consiglio => consiglioCapi(_membri, _squadriglie);

  /// Ragazzi tra cui scegliere i membri di un sottogruppo.
  List<MembroUnita> get ragazzi => _membri
      .where((m) => const {'RAGAZZO', 'VICE_CAPO_SQ', 'CAPO_SQ'}.contains(m.ruolo))
      .toList();

  /// Membri attuali del sottogruppo [tipo]: chi ha lasciato l'unità non compare.
  List<MembroUnita> membriSottogruppo(TipoSottogruppo tipo) {
    final scelti = _sottogruppi
        .where((s) => s.tipo == tipo)
        .expand((s) => s.membri)
        .toSet();
    return _membri.where((m) => scelti.contains(m.id)).toList();
  }

  /// Motivo per cui [nome] non è valido, o `null`.
  String? erroreNome(String nome, {String? escludiId}) =>
      erroreNomeSquadriglia(nome, _squadriglie, escludiId: escludiId);

  /// Crea una squadriglia. Gli errori vengono propagati alla View.
  Future<void> crea(String nome) => _repository.creaSquadriglia(nome);

  /// Cambia il nome di [s]: i membri restano, perché sono legati al suo id.
  Future<void> rinomina(Squadriglia s, String nome) =>
      _repository.aggiornaSquadriglia(s.copyWith(nome: nome));

  /// Cambia l'urlo di [s].
  Future<void> impostaUrlo(Squadriglia s, String urlo) =>
      _repository.aggiornaSquadriglia(s.copyWith(urlo: urlo));

  /// Disattiva [s]; rifiutata se ci sono ancora ragazzi, che resterebbero in
  /// una squadriglia che non si può più scegliere.
  Future<void> disattiva(Squadriglia s) async {
    if (membriDella(s).isNotEmpty) {
      throw const JambException(
        TipoErrore.datiNonValidi,
        'Sposta prima i ragazzi in un\'altra squadriglia.',
      );
    }
    await _repository.aggiornaSquadriglia(s.copyWith(attiva: false));
  }

  /// Riattiva [s].
  Future<void> riattiva(Squadriglia s) =>
      _repository.aggiornaSquadriglia(s.copyWith(attiva: true));

  /// Sostituisce i membri del sottogruppo [tipo].
  Future<void> salvaMembri(TipoSottogruppo tipo, Set<String> membri) =>
      _repository.salvaMembri(tipo, membri);
}
