import 'package:flutter/foundation.dart';
import '../../domain/entities/scout.dart';

/// Interfaccia per il Repository degli Scout.
/// Estende ChangeNotifier per permettere ai ViewModel di ascoltare i cambiamenti dei dati.
abstract class IScoutRepository extends ChangeNotifier {
  Future<List<Scout>> getRagazzi();
  Future<void> salvaRagazzo(Scout ragazzo);
}
