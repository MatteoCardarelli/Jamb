import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';

/// Repository delle transazioni finto (in memoria) per i test dei ViewModel.
///
/// [erroreLettura], se impostato, viene sollevato da [getTransazioni] e da
/// [urlRicevuta]; [ricevuteSalvate] registra le ricevute passate al salvataggio.
class FakeTransazioneRepository extends ChangeNotifier
    implements ITransazioneRepository {
  final List<Transazione> data;
  final List<FileDaCaricare?> ricevuteSalvate = [];
  final List<String> urlRichiesti = [];
  JambException? erroreLettura;

  FakeTransazioneRepository(this.data, {this.erroreLettura});

  @override
  Future<List<Transazione>> getTransazioni() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(data);
  }

  @override
  Future<void> salvaTransazione(Transazione transazione, {FileDaCaricare? ricevuta}) async {
    ricevuteSalvate.add(ricevuta);
  }

  @override
  Future<void> eliminaTransazione(String id) async {}

  @override
  Future<String> urlRicevuta(String percorso) async {
    urlRichiesti.add(percorso);
    if (erroreLettura != null) throw erroreLettura!;
    return 'https://archivio.test/ricevute/$percorso';
  }
}
