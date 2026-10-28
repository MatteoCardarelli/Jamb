import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';

/// Repository degli scout finto (in memoria) per i test dei ViewModel.
///
/// [erroreLettura] ed [erroreScrittura], se impostati, vengono sollevati
/// rispettivamente dalle letture e dai salvataggi.
class FakeScoutRepository extends ChangeNotifier implements IScoutRepository {
  final List<Scout> data;
  JambException? erroreLettura;
  JambException? erroreScrittura;

  FakeScoutRepository(this.data, {this.erroreLettura, this.erroreScrittura});

  @override
  Future<List<Scout>> getRagazzi() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(data);
  }

  @override
  Future<void> salvaRagazzo(Scout ragazzo) async {
    if (erroreScrittura != null) throw erroreScrittura!;
  }

  @override
  Future<List<String>> getSquadriglie() async {
    if (erroreLettura != null) throw erroreLettura!;
    return data.map((e) => e.squadriglia).toSet().toList();
  }
}
