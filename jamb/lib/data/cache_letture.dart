import 'package:jamb/data/errori_supabase.dart';

/// Memorizza per poco tempo i risultati delle letture, per non ripetere al
/// server richieste già fatte.
///
/// Vive in memoria ed è ricreata a ogni cambio di utente o di unità, come i
/// repository. Due letture uguali contemporanee (ad esempio Home e Ragazzi
/// all'avvio) diventano una sola. Una scrittura dimentica le chiavi che tocca,
/// così chi scrive rivede subito i propri dati; le modifiche degli altri capi
/// arrivano al più tardi dopo [durata]. Gli errori non si memorizzano.
class CacheLetture {
  /// Per quanto un risultato resta valido.
  final Duration durata;
  final DateTime Function() _adesso;
  final Map<String, _Voce> _voci = {};

  CacheLetture({
    this.durata = const Duration(minutes: 5),
    DateTime Function()? adesso,
  }) : _adesso = adesso ?? DateTime.now;

  /// Risultato di [lettura] per [chiave], riusato se ancora valido.
  Future<T> leggi<T>(String chiave, Future<T> Function() lettura) async {
    final esistente = _voci[chiave];
    if (esistente != null && _adesso().isBefore(esistente.scadenza)) {
      return _copia(await (esistente.valore as Future<T>));
    }

    final voce = _Voce(lettura(), _adesso().add(durata));
    _voci[chiave] = voce;
    try {
      return _copia(await (voce.valore as Future<T>));
    } catch (_) {
      // Solo se nel frattempo non è stata sostituita da una lettura più nuova.
      if (identical(_voci[chiave], voce)) _voci.remove(chiave);
      rethrow;
    }
  }

  /// Come [leggi], per una lettura da Supabase con i suoi errori tradotti.
  Future<T> leggiSupabase<T>(String chiave, Future<T> Function() lettura) =>
      leggi(chiave, () => eseguiSupabase(lettura));

  /// Dimentica le chiavi che iniziano con uno dei [prefissi]. Una lettura in
  /// corso non viene più riusata, quindi non può riportare dati vecchi.
  void dimentica(List<String> prefissi) {
    _voci.removeWhere((chiave, _) => prefissi.any(chiave.startsWith));
  }

  /// I ViewModel ordinano le liste che ricevono: ognuno ha la sua copia.
  T _copia<T>(T valore) => valore is List ? valore.toList() as T : valore;
}

class _Voce {
  final Future<Object?> valore;
  final DateTime scadenza;

  _Voce(this.valore, this.scadenza);
}
