import 'package:flutter/foundation.dart';
import 'package:jamb/domain/repositories/preferenze_repository.dart';

/// Preferenze dell'utente (US3), lette dalla Home e modificate dal profilo.
class PreferenzeViewModel extends ChangeNotifier {
  final IPreferenzeRepository _repository;

  Preferenze _preferenze = const Preferenze();
  bool _eliminato = false;

  PreferenzeViewModel(this._repository) {
    _carica();
  }

  @override
  void dispose() {
    _eliminato = true;
    super.dispose();
  }

  Future<void> _carica() async {
    _preferenze = await _repository.leggi();
    if (!_eliminato) notifyListeners();
  }

  bool get mostraPillole => _preferenze.mostraPillole;
  bool get mostraCassa => _preferenze.mostraCassa;

  /// Mostra o nasconde la pillola nella Home.
  Future<void> setMostraPillole(bool valore) =>
      _aggiorna(_preferenze.copyWith(mostraPillole: valore));

  /// Mostra o nasconde la cassa nella Home.
  Future<void> setMostraCassa(bool valore) =>
      _aggiorna(_preferenze.copyWith(mostraCassa: valore));

  /// La scelta vale subito; se non si salva torna quella di prima e l'errore
  /// arriva alla View.
  Future<void> _aggiorna(Preferenze nuove) async {
    final precedenti = _preferenze;
    _preferenze = nuove;
    notifyListeners();
    try {
      await _repository.salva(nuove);
    } catch (_) {
      _preferenze = precedenti;
      notifyListeners();
      rethrow;
    }
  }
}
