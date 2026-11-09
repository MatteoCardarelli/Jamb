import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/campo_repository.dart';

/// Repository dei campi finto (in memoria) per i test dei ViewModel.
class FakeCampoRepository extends ChangeNotifier implements ICampoRepository {
  final List<Campo> campi;
  final List<MembroUnita> staff;
  final List<Pattuglia> pattuglie = [];
  final List<CompitoCampo> compiti = [];
  final List<ContattoCampo> contatti = [];
  JambException? erroreLettura;
  int _id = 1;

  FakeCampoRepository({List<Campo>? campi, List<MembroUnita>? staff})
      : campi = campi ?? [],
        staff = staff ?? [];

  @override
  Future<List<Campo>> getCampi() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(campi);
  }

  @override
  Future<Campo?> getCampo(String id) async {
    if (erroreLettura != null) throw erroreLettura!;
    for (final c in campi) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<Campo> creaCampo(TipoCampo tipo, String titolo) async {
    final campo = Campo(id: 'campo${_id++}', tipo: tipo, titolo: titolo);
    campi.add(campo);
    notifyListeners();
    return campo;
  }

  @override
  Future<void> aggiornaCampo(Campo c) async {
    campi[campi.indexWhere((x) => x.id == c.id)] = c;
    notifyListeners();
  }

  @override
  Future<void> eliminaCampo(String id) async {
    campi.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  @override
  Future<List<MembroUnita>> getStaff() async => List.of(staff);

  @override
  Future<List<Pattuglia>> getPattuglie(String campoId) async => List.of(pattuglie);

  @override
  Future<void> creaPattuglia(String campoId, String nome) async {
    pattuglie.add(Pattuglia(id: 'p${_id++}', nome: nome));
    notifyListeners();
  }

  @override
  Future<void> rinominaPattuglia(String id, String nome) async {
    final i = pattuglie.indexWhere((p) => p.id == id);
    pattuglie[i] = Pattuglia(id: id, nome: nome, membri: pattuglie[i].membri);
    notifyListeners();
  }

  @override
  Future<void> salvaMembriPattuglia(String id, Set<String> membri) async {
    final i = pattuglie.indexWhere((p) => p.id == id);
    pattuglie[i] = Pattuglia(id: id, nome: pattuglie[i].nome, membri: membri);
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

  @override
  Future<List<ContattoCampo>> getContatti(String campoId) async => List.of(contatti);

  @override
  Future<void> creaContatto(String campoId, String etichetta, String telefono) async {
    contatti.add(ContattoCampo(id: 't${_id++}', etichetta: etichetta, telefono: telefono));
    notifyListeners();
  }

  @override
  Future<void> eliminaContatto(String id) async {
    contatti.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
