import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';

/// Repository degli scout finto (in memoria) per i test dei ViewModel.
class FakeScoutRepository extends ChangeNotifier implements IScoutRepository {
  final List<Scout> data;
  FakeScoutRepository(this.data);

  @override
  Future<List<Scout>> getRagazzi() async => List.of(data);

  @override
  Future<void> salvaRagazzo(Scout ragazzo) async {}

  @override
  Future<List<String>> getSquadriglie() async =>
      data.map((e) => e.squadriglia).toSet().toList();
}