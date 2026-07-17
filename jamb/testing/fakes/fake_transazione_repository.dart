import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';

/// Repository delle transazioni finto (in memoria) per i test dei ViewModel.
class FakeTransazioneRepository extends ChangeNotifier
    implements ITransazioneRepository {
  final List<Transazione> data;
  FakeTransazioneRepository(this.data);

  @override
  Future<List<Transazione>> getTransazioni() async => List.of(data);

  @override
  Future<void> salvaTransazione(Transazione transazione) async {}

  @override
  Future<void> eliminaTransazione(String id) async {}
}