import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/nuovo_ragazzo.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato del form per aggiungere ragazzi all'unità attiva, uno dopo l'altro:
/// dopo ogni salvataggio [preparaProssimo] svuota i campi ma tiene la
/// squadriglia, perché spesso si caricano più ragazzi della stessa.
///
/// Le squadriglie si caricano all'apertura; se non arrivano si può comunque
/// aggiungere il ragazzo senza squadriglia.
class AggiungiRagazzoViewModel extends ChangeNotifier
    with StatoCaricamentoMixin {
  final IScoutRepository _repository;
  final DateTime Function() _oggi;

  String _nome = '';
  String _cognome = '';
  DateTime? _dataNascita;
  String _squadriglia = '';
  String _ruolo = 'RAGAZZO';
  List<String> _squadriglie = const [];
  int _aggiunti = 0;

  AggiungiRagazzoViewModel(this._repository, {DateTime Function()? oggi})
    : _oggi = oggi ?? DateTime.now {
    _caricaSquadriglie();
  }

  String get nome => _nome;
  String get cognome => _cognome;
  DateTime? get dataNascita => _dataNascita;

  /// Squadriglia scelta; vuota se nessuna.
  String get squadriglia => _squadriglia;

  /// Uno tra [ruoliRagazzo].
  String get ruolo => _ruolo;

  /// Squadriglie attive dell'unità.
  List<String> get squadriglie => _squadriglie;

  /// Ragazzi aggiunti da quando il form è aperto.
  int get aggiunti => _aggiunti;

  Future<void> _caricaSquadriglie() => eseguiCaricamento(() async {
    _squadriglie = await _repository.getSquadriglie();
  });

  /// Riprova a caricare le squadriglie (es. dopo un errore).
  Future<void> ricaricaSquadriglie() => _caricaSquadriglie();

  void setNome(String valore) {
    _nome = valore;
    notifyListeners();
  }

  void setCognome(String valore) {
    _cognome = valore;
    notifyListeners();
  }

  void setDataNascita(DateTime? valore) {
    _dataNascita = valore;
    notifyListeners();
  }

  /// Sceglie la squadriglia; toccando quella già scelta la si toglie.
  void setSquadriglia(String valore) {
    _squadriglia = _squadriglia.toLowerCase() == valore.toLowerCase()
        ? ''
        : valore;
    notifyListeners();
  }

  void setRuolo(String valore) {
    if (!ruoliRagazzo.contains(valore)) return;
    _ruolo = valore;
    notifyListeners();
  }

  /// Motivo per cui la data di nascita non va bene, o `null`.
  String? get erroreDataNascita {
    final data = _dataNascita;
    if (data == null) return null;
    final oggi = _oggi();
    return data.isAfter(DateTime(oggi.year, oggi.month, oggi.day))
        ? 'La data di nascita non può essere nel futuro.'
        : null;
  }

  bool get isValid =>
      _nome.trim().isNotEmpty &&
      _cognome.trim().isNotEmpty &&
      erroreDataNascita == null;

  /// Aggiunge il ragazzo all'unità (nessuna scrittura se il form non è
  /// valido). Un errore viene propagato alla View.
  Future<void> salva() async {
    if (!isValid) return;
    await _repository.aggiungiRagazzo(
      NuovoRagazzo(
        nome: _nome.trim(),
        cognome: _cognome.trim(),
        dataNascita: _dataNascita,
        squadriglia: _squadriglia.isEmpty ? null : _squadriglia,
        ruolo: _ruolo,
      ),
    );
    _aggiunti++;
    notifyListeners();
  }

  /// Svuota il form per il ragazzo successivo, tenendo la squadriglia.
  void preparaProssimo() {
    _nome = '';
    _cognome = '';
    _dataNascita = null;
    _ruolo = 'RAGAZZO';
    notifyListeners();
  }
}
