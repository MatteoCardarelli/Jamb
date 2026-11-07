import 'package:flutter/foundation.dart';
import '../../domain/entities/presenza.dart';

/// Contratto per l'accesso all'appello delle presenze agli eventi.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class IPresenzaRepository extends ChangeNotifier {
  /// Appello già registrato per l'evento [eventoId]: id del ragazzo → stato.
  /// I ragazzi non ancora segnati non compaiono.
  Future<Map<String, StatoPresenza>> getAppello(String eventoId);

  /// Salva in un'unica scrittura gli [stati] dei ragazzi all'evento
  /// [eventoId], sostituendo quelli già registrati.
  Future<void> salvaAppello(String eventoId, Map<String, StatoPresenza> stati);

  /// Presenze del ragazzo [ragazzoId] agli eventi, dal più recente.
  Future<List<PresenzaRagazzo>> getStorico(String ragazzoId);
}
