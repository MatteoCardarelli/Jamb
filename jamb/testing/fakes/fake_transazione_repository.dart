import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';

/// Repository delle transazioni finto (in memoria) per i test dei ViewModel.
///
/// [erroreLettura], se impostato, viene sollevato da [getTransazioni].
class FakeTransazioneRepository extends ChangeNotifier
    implements ITransazioneRepository {
  final List<Transazione> data;
  JambException? erroreLettura;

  FakeTransazioneRepository(this.data, {this.erroreLettura});

  @override
  Future<List<Transazione>> getTransazioni() async {
    if (erroreLettura != null) throw erroreLettura!;
    return List.of(data);
  }

  @override
  Future<void> salvaTransazione(Transazione transazione) async {}

  @override
  Future<void> eliminaTransazione(String id) async {}
}
