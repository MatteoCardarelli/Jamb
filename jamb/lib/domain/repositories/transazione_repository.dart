import 'package:flutter/foundation.dart';
import '../../domain/entities/file_da_caricare.dart';
import '../../domain/entities/transazione.dart';

/// Contratto per l'accesso alle transazioni di cassa.
///
/// Estende [ChangeNotifier] per la ricarica reattiva dei ViewModel.
abstract class ITransazioneRepository extends ChangeNotifier {
  /// Transazioni dell'unità attiva, ordinate per data decrescente.
  Future<List<Transazione>> getTransazioni();

  /// Inserisce (id temporaneo non-UUID) o aggiorna (id UUID) la [transazione].
  /// Per una transazione nuova, [ricevuta] è la foto dello scontrino da
  /// archiviare insieme alla riga.
  Future<void> salvaTransazione(Transazione transazione, {FileDaCaricare? ricevuta});

  /// Elimina la transazione con l'[id] indicato, con la sua ricevuta.
  Future<void> eliminaTransazione(String id);

  /// URL temporaneo per vedere la ricevuta archiviata al [percorso].
  Future<String> urlRicevuta(String percorso);
}
