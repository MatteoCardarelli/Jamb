import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:jamb/domain/entities/anno_scout.dart';
import 'package:jamb/domain/entities/bilancio.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';
import 'package:jamb/ui/contabilita/bilancio_export.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Bilancio consolidato dell'unità attiva (US26): scelta dell'anno scout,
/// riepilogo e archiviazione in PDF o CSV nel Drive di Branca.
class BilancioViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final ITransazioneRepository _transazioni;
  final IDocumentoRepository _documenti;
  final DateTime _oggi;

  List<Transazione> _tutte = const [];
  late String _annoScout = annoScoutDi(_oggi);

  /// [oggi] serve solo ai test.
  BilancioViewModel(this._transazioni, this._documenti, {DateTime? oggi})
      : _oggi = oggi ?? DateTime.now() {
    _transazioni.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _transazioni.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _tutte = await _transazioni.getTransazioni();
      });

  /// Rilegge le transazioni (es. dopo un errore).
  Future<void> ricarica() => _carica();

  /// Anno scout selezionato.
  String get annoScout => _annoScout;

  /// Anni scout selezionabili, dal più recente.
  List<String> get anni => anniDiBilancio(_tutte, _oggi);

  /// Bilancio dell'anno selezionato.
  Bilancio get bilancio => Bilancio.daTransazioni(_tutte, _annoScout);

  /// Seleziona l'anno scout [anno].
  void scegliAnno(String anno) {
    if (anno == _annoScout) return;
    _annoScout = anno;
    notifyListeners();
  }

  /// Nome del file archiviato il giorno [data]; la data distingue le versioni.
  static String nomeFile(String annoScout, DateTime data, String estensione) =>
      'Bilancio $annoScout - ${DateFormat('dd-MM-yyyy').format(data)}.$estensione';

  /// Archivia il bilancio selezionato in PDF nel Drive di Branca e restituisce
  /// il documento creato, da aprire. Un errore viene propagato alla View.
  Future<Documento> archiviaPdf({required String unita}) async {
    final pdf = await generaBilancioPdf(unita: unita, bilancio: bilancio, data: _oggi);
    return _archivia(pdf, 'pdf');
  }

  /// Archivia il bilancio selezionato in CSV nel Drive di Branca e restituisce
  /// il documento creato, da aprire. Un errore viene propagato alla View.
  Future<Documento> archiviaCsv({required String unita}) =>
      _archivia(generaBilancioCsv(unita: unita, bilancio: bilancio), 'csv');

  /// URL temporaneo per aprire il [documento] archiviato.
  Future<String> urlFile(Documento documento) => _documenti.urlFile(documento);

  Future<Documento> _archivia(Uint8List byte, String estensione) => _documenti.caricaFile(
        ArchivioDocumenti.driveBranca,
        FileDaCaricare(nome: nomeFile(_annoScout, _oggi, estensione), byte: byte),
        null,
      );
}
