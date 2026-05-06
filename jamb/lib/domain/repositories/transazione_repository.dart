import 'package:flutter/foundation.dart';
import '../../domain/entities/transazione.dart';

/// Interfaccia per il Repository delle Transazioni.
/// Estende ChangeNotifier per permettere ai ViewModel di ascoltare i cambiamenti.
abstract class ITransazioneRepository extends ChangeNotifier {
  Future<List<Transazione>> getTransazioni();
  Future<void> salvaTransazione(Transazione transazione);
  Future<void> eliminaTransazione(String id);
}
