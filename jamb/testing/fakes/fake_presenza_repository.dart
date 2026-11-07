import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/presenza.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/presenza_repository.dart';

/// Repository dell'appello finto (in memoria) per i test dei ViewModel.
///
/// [appelli] contiene gli appelli già registrati per evento; [salvataggi]
/// registra ogni chiamata a [salvaAppello]. Come quello reale notifica
/// dopo ogni scrittura.
class FakePresenzaRepository extends ChangeNotifier
    implements IPresenzaRepository {
  final Map<String, Map<String, StatoPresenza>> appelli;
  final Map<String, List<PresenzaRagazzo>> storici;
  final List<Map<String, StatoPresenza>> salvataggi = [];
  JambException? erroreLettura;
  JambException? erroreScrittura;

  FakePresenzaRepository({
    Map<String, Map<String, StatoPresenza>>? appelli,
    Map<String, List<PresenzaRagazzo>>? storici,
    this.erroreLettura,
    this.erroreScrittura,
  })  : appelli = appelli ?? {},
        storici = storici ?? {};

  @override
  Future<Map<String, StatoPresenza>> getAppello(String eventoId) async {
    if (erroreLettura != null) throw erroreLettura!;
    return Map.of(appelli[eventoId] ?? const {});
  }

  @override
  Future<void> salvaAppello(
    String eventoId,
    Map<String, StatoPresenza> stati,
  ) async {
    if (erroreScrittura != null) throw erroreScrittura!;
    salvataggi.add(Map.of(stati));
    appelli.putIfAbsent(eventoId, () => {}).addAll(stati);
    notifyListeners();
  }

  @override
  Future<List<PresenzaRagazzo>> getStorico(String ragazzoId) async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(storici[ragazzoId] ?? const []);
  }
}
