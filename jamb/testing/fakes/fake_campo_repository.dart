import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/campo_repository.dart';

/// Repository del campo finto (in memoria) per i test dei ViewModel.
class FakeCampoRepository extends ChangeNotifier implements ICampoRepository {
  Campo? campo;
  final List<Pattuglia> pattuglie = [];
  final List<CompitoCampo> compiti = [];
  JambException? erroreLettura;
  int _id = 1;

  FakeCampoRepository({this.campo});

  @override
  Future<Campo?> getCampo() async {
    if (erroreLettura != null) throw erroreLettura!;
    return campo;
  }

  @override
  Future<void> creaCampo(String titolo) async {
    campo = Campo(id: 'campo', titolo: titolo);
    notifyListeners();
  }

  @override
  Future<void> aggiornaCampo(Campo c) async {
    campo = c;
    notifyListeners();
  }

  @override
  Future<List<Pattuglia>> getPattuglie(String campoId) async => List.of(pattuglie);

  @override
  Future<void> creaPattuglia(String campoId, String nome) async {
    pattuglie.add(Pattuglia(id: 'p${_id++}', nome: nome));
    notifyListeners();
  }

  @override
  Future<void> rinominaPattuglia(String id, String nome) async {
    pattuglie[pattuglie.indexWhere((p) => p.id == id)] = Pattuglia(id: id, nome: nome);
    notifyListeners();
  }

  @override
  Future<void> eliminaPattuglia(String id) async {
    pattuglie.removeWhere((p) => p.id == id);
    // Come la cascata del database.
    compiti.removeWhere((c) => c.pattugliaId == id);
    notifyListeners();
  }

  @override
  Future<List<CompitoCampo>> getCompiti(Iterable<String> ids) async =>
      compiti.where((c) => ids.contains(c.pattugliaId)).toList();

  @override
  Future<void> creaCompito(String pattugliaId, String titolo) async {
    compiti.add(CompitoCampo(id: 'c${_id++}', pattugliaId: pattugliaId, titolo: titolo));
    notifyListeners();
  }

  @override
  Future<void> impostaStato(String id, StatoCompito stato) async {
    final i = compiti.indexWhere((c) => c.id == id);
    final c = compiti[i];
    compiti[i] = CompitoCampo(id: c.id, pattugliaId: c.pattugliaId, titolo: c.titolo, stato: stato);
    notifyListeners();
  }

  @override
  Future<void> eliminaCompito(String id) async {
    compiti.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
