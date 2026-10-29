import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/avviso.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/avviso_repository.dart';

/// Repository della bacheca finto (in memoria) per i test dei ViewModel.
///
/// Come quello reale notifica dopo ogni scrittura; [erroreLettura] ed
/// [erroreScrittura], se impostati, vengono sollevati da letture e scritture.
class FakeAvvisoRepository extends ChangeNotifier implements IAvvisoRepository {
  final List<Avviso> data;
  final List<Avviso> creati = [];
  final List<Avviso> aggiornati = [];
  final List<String> eliminati = [];
  final List<String> letti = [];
  JambException? erroreLettura;
  JambException? erroreScrittura;

  FakeAvvisoRepository(this.data, {this.erroreLettura, this.erroreScrittura});

  @override
  Future<List<Avviso>> getAvvisi() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(data);
  }

  @override
  Future<void> creaAvviso(Avviso avviso) => _scrivi(() => creati.add(avviso));

  @override
  Future<void> aggiornaAvviso(Avviso avviso) =>
      _scrivi(() => aggiornati.add(avviso));

  @override
  Future<void> eliminaAvviso(String id) => _scrivi(() => eliminati.add(id));

  @override
  Future<void> segnaComeLetto(String id) => _scrivi(() {
        letti.add(id);
        final i = data.indexWhere((a) => a.id == id);
        if (i >= 0) data[i] = _letto(data[i]);
      });

  Future<void> _scrivi(void Function() scrittura) async {
    if (erroreScrittura != null) throw erroreScrittura!;
    scrittura();
    notifyListeners();
  }

  static Avviso _letto(Avviso a) => Avviso(
        id: a.id,
        titolo: a.titolo,
        contenuto: a.contenuto,
        dataPubblicazione: a.dataPubblicazione,
        autore: a.autore,
        squadriglia: a.squadriglia,
        letto: true,
      );
}
