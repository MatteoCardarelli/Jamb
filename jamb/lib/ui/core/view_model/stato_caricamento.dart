import 'package:flutter/foundation.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';

/// Stato di una lettura asincrona dei dati di una schermata.
///
/// L'elenco vuoto non è uno stato a sé: si ricava dai dati quando lo stato
/// è [pronto], così non può contraddirli.
enum StatoCaricamento { caricamento, pronto, errore }

/// Gestione uniforme dello stato di caricamento per i ViewModel.
///
/// Le letture passano da [eseguiCaricamento]: un errore non resta silenzioso
/// ma diventa lo stato [StatoCaricamento.errore], con un messaggio da
/// mostrare e la possibilità di riprovare.
mixin StatoCaricamentoMixin on ChangeNotifier {
  StatoCaricamento _stato = StatoCaricamento.caricamento;
  String? _errore;
  bool _eliminato = false;

  StatoCaricamento get stato => _stato;
  bool get isLoading => _stato == StatoCaricamento.caricamento;
  bool get haErrore => _stato == StatoCaricamento.errore;

  /// Messaggio dell'ultima lettura fallita (`null` se non c'è errore).
  String? get errore => _errore;

  /// Esegue la [lettura] aggiornando lo stato prima e dopo.
  Future<void> eseguiCaricamento(Future<void> Function() lettura) async {
    _stato = StatoCaricamento.caricamento;
    _errore = null;
    _notifica();

    try {
      await lettura();
      _stato = StatoCaricamento.pronto;
    } catch (e, stackTrace) {
      debugPrint('Errore di caricamento in $runtimeType: $e\n$stackTrace');
      _errore = JambException.messaggioPer(e);
      _stato = StatoCaricamento.errore;
    }
    _notifica();
  }

  /// Notifica solo se il ViewModel è ancora vivo: una lettura può terminare
  /// dopo che l'utente ha già lasciato la schermata.
  void _notifica() {
    if (!_eliminato) notifyListeners();
  }

  @override
  void dispose() {
    _eliminato = true;
    super.dispose();
  }
}
