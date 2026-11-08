import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/incarichi.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/incarichi_repository.dart';

/// Repository degli incarichi finto (in memoria) per i test dei ViewModel.
class FakeIncarichiRepository extends ChangeNotifier implements IIncarichiRepository {
  final List<PersonaGruppo> persone;
  final Set<String> assistenti;
  JambException? erroreLettura;

  FakeIncarichiRepository(this.persone, {Set<String>? assistenti}) : assistenti = assistenti ?? {};

  @override
  Future<List<PersonaGruppo>> getAssistenti() async {
    if (erroreLettura != null) throw erroreLettura!;
    return persone.where((p) => assistenti.contains(p.id)).toList();
  }

  @override
  Future<List<PersonaGruppo>> getPersone() async => List.of(persone);

  @override
  Future<void> nomina(String userId) async {
    assistenti.add(userId);
    notifyListeners();
  }

  @override
  Future<void> revoca(String userId) async {
    assistenti.remove(userId);
    notifyListeners();
  }
}
