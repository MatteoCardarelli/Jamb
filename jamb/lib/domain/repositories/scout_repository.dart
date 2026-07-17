import 'package:flutter/foundation.dart';
import '../../domain/entities/scout.dart';

/// Contratto per l'accesso ai dati degli scout (ragazzi).
///
/// Estende [ChangeNotifier] così i ViewModel in ascolto possono ricaricarsi
/// automaticamente quando i dati cambiano (pattern reattivo).
abstract class IScoutRepository extends ChangeNotifier {
  /// Restituisce i ragazzi dell'unità attiva (ruoli RAGAZZO/VICE_CAPO_SQ/CAPO_SQ),
  /// ordinati alfabeticamente per cognome e nome.
  Future<List<Scout>> getRagazzi();

  /// Salva lo scout [ragazzo]: progressione, dati sensibili, stati
  /// amministrativi e — se cambiati — ruolo/squadriglia (membership SCD Type 2).
  Future<void> salvaRagazzo(Scout ragazzo);

  /// Nomi delle squadriglie attive dell'unità corrente.
  Future<List<String>> getSquadriglie();
}
