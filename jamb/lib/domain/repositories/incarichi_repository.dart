import 'package:flutter/foundation.dart';
import '../entities/incarichi.dart';

/// Contratto per gli incarichi trasversali del gruppo.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IIncarichiRepository extends ChangeNotifier {
  /// Assistenti Ecclesiastici del gruppo.
  Future<List<PersonaGruppo>> getAssistenti();

  /// Persone del gruppo, con o senza un'unità.
  Future<List<PersonaGruppo>> getPersone();

  /// Nomina Assistente Ecclesiastico la persona [userId].
  Future<void> nomina(String userId);

  /// Toglie l'incarico alla persona [userId].
  Future<void> revoca(String userId);
}
