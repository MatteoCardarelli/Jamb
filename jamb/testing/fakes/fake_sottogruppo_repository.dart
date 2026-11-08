import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/sottogruppo_repository.dart';

/// Repository dei sottogruppi finto (in memoria) per i test dei ViewModel.
class FakeSottogruppoRepository extends ChangeNotifier implements ISottogruppoRepository {
  final List<Squadriglia> squadriglie;
  final List<MembroUnita> membri;
  final List<Sottogruppo> sottogruppi;
  JambException? erroreLettura;
  int _prossimoId = 1;

  FakeSottogruppoRepository({
    List<Squadriglia>? squadriglie,
    List<MembroUnita>? membri,
    List<Sottogruppo>? sottogruppi,
  })  : squadriglie = squadriglie ?? [],
        membri = membri ?? [],
        sottogruppi = sottogruppi ?? [];

  @override
  Future<List<Squadriglia>> getSquadriglie() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(squadriglie);
  }

  @override
  Future<List<MembroUnita>> getMembriUnita() async => List.of(membri);

  @override
  Future<List<Sottogruppo>> getSottogruppi() async => List.of(sottogruppi);

  @override
  Future<void> creaSquadriglia(String nome) async {
    squadriglie.add(Squadriglia(id: 'nuova-${_prossimoId++}', nome: nome));
    notifyListeners();
  }

  @override
  Future<void> aggiornaSquadriglia(Squadriglia squadriglia) async {
    final i = squadriglie.indexWhere((s) => s.id == squadriglia.id);
    final vecchia = squadriglie[i];
    squadriglie[i] = squadriglia;
    // Come nel DB: i membri sono legati all'id, il nome segue la squadriglia.
    for (var m = 0; m < membri.length; m++) {
      if (membri[m].squadriglia == vecchia.nome) {
        membri[m] = MembroUnita(
          id: membri[m].id,
          nome: membri[m].nome,
          ruolo: membri[m].ruolo,
          squadriglia: squadriglia.nome,
        );
      }
    }
    notifyListeners();
  }

  @override
  Future<void> salvaMembri(TipoSottogruppo tipo, Set<String> scelti) async {
    sottogruppi
      ..removeWhere((s) => s.tipo == tipo)
      ..add(Sottogruppo(tipo: tipo, membri: scelti));
    notifyListeners();
  }
}
