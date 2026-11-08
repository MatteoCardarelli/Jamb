import 'package:flutter/foundation.dart';
import '../entities/sottogruppi.dart';

/// Contratto per squadriglie e sottogruppi dell'unità attiva.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class ISottogruppoRepository extends ChangeNotifier {
  /// Squadriglie dell'unità, anche disattivate, in ordine di nome.
  Future<List<Squadriglia>> getSquadriglie();

  /// Persone con una membership attiva nell'unità.
  Future<List<MembroUnita>> getMembriUnita();

  /// Sottogruppi dell'unità già creati, con i loro membri.
  Future<List<Sottogruppo>> getSottogruppi();

  /// Crea la squadriglia [nome] nell'unità attiva.
  Future<void> creaSquadriglia(String nome);

  /// Salva nome, urlo e stato di [squadriglia].
  Future<void> aggiornaSquadriglia(Squadriglia squadriglia);

  /// Sostituisce i membri del sottogruppo [tipo] con [membri], in un'unica
  /// transazione; il sottogruppo viene creato se non esiste.
  Future<void> salvaMembri(TipoSottogruppo tipo, Set<String> membri);
}
