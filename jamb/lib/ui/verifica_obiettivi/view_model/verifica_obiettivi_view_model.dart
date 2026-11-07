import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamb/domain/entities/anno_scout.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/ui/verifica_obiettivi/programma_pdf.dart';

/// ViewModel per la gestione dello stato della schermata di verifica obiettivi.
/// Mantiene una lista locale di obiettivi che può essere modificata prima del
/// salvataggio, e può archiviarla in PDF nel Drive di Branca (US17).
class VerificaObiettiviViewModel extends ChangeNotifier {
  final List<Obiettivo> _obiettivi;
  final IDocumentoRepository _documenti;

  VerificaObiettiviViewModel(List<Obiettivo> initialObiettivi, this._documenti)
      : _obiettivi = List.from(initialObiettivi);

  /// Nome del PDF archiviato il giorno [oggi], es.
  /// "Programma d'Unità 2026-2027 - 07-11-2026.pdf": la data distingue le
  /// versioni archiviate nello stesso anno.
  static String nomeFileProgramma(DateTime oggi) =>
      "Programma d'Unità ${annoScoutDi(oggi)} - ${DateFormat('dd-MM-yyyy').format(oggi)}.pdf";

  /// Archivia il Programma così come appare ora (anche con modifiche non
  /// ancora salvate) in PDF, nella radice del Drive di Branca dell'unità.
  /// [oggi] serve solo ai test. Un errore viene propagato alla View.
  Future<void> archiviaNelDrive({required String unita, DateTime? oggi}) async {
    final data = oggi ?? DateTime.now();
    final pdf = await generaProgrammaPdf(
      unita: unita,
      annoScout: annoScoutDi(data),
      obiettivi: _obiettivi,
      data: data,
    );
    await _documenti.caricaFile(
      ArchivioDocumenti.driveBranca,
      FileDaCaricare(nome: nomeFileProgramma(data), byte: pdf),
      null,
    );
  }

  /// Getter per la lista degli obiettivi correnti
  List<Obiettivo> get obiettivi => _obiettivi;

  /// Aggiorna il punteggio (grado) di un obiettivo specifico
  void updateScore(int index, int newScore) {
    if (index >= 0 && index < _obiettivi.length) {
      _obiettivi[index] = _obiettivi[index].copyWith(grado: newScore);
      notifyListeners();
    }
  }

  /// Aggiorna un obiettivo esistente
  void updateObiettivo(int index, Obiettivo updated) {
    if (index >= 0 && index < _obiettivi.length) {
      _obiettivi[index] = updated;
      notifyListeners();
    }
  }

  /// Aggiunge un nuovo obiettivo alla lista
  void addObiettivo(Obiettivo nuovo) {
    _obiettivi.add(nuovo);
    notifyListeners();
  }

  /// Elimina un obiettivo dalla lista
  void removeObiettivo(int index) {
    if (index >= 0 && index < _obiettivi.length) {
      _obiettivi.removeAt(index);
      notifyListeners();
    }
  }

  /// Restituisce la lista dei colori già in uso dagli obiettivi (escludendo opzionalmente uno specifico ID)
  List<Color> getOccupiedColors({String? excludeId}) {
    return _obiettivi
        .where((o) => o.id != excludeId)
        .map((o) => o.colore)
        .toList();
  }
}
