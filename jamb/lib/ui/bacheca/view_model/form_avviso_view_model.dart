import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/avviso.dart';
import 'package:jamb/domain/repositories/avviso_repository.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Stato del form avviso, per pubblicarne uno nuovo o modificare
/// [avvisoEsistente]: oggetto, messaggio e destinatari (tutta l'unità o una
/// squadriglia).
class FormAvvisoViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IAvvisoRepository _avvisoRepository;
  final IScoutRepository _scoutRepository;
  final Avviso? _avvisoEsistente;

  late String _titolo;
  late String _contenuto;
  String? _squadriglia;
  List<String> _squadriglieDisponibili = const [];

  FormAvvisoViewModel(
    this._avvisoRepository,
    this._scoutRepository, {
    Avviso? avvisoEsistente,
  }) : _avvisoEsistente = avvisoEsistente {
    _titolo = avvisoEsistente?.titolo ?? '';
    _contenuto = avvisoEsistente?.contenuto ?? '';
    _squadriglia = avvisoEsistente?.squadriglia;
    _caricaSquadriglie();
  }

  /// `true` se il form modifica un avviso esistente.
  bool get isModifica => _avvisoEsistente != null;

  String get titolo => _titolo;
  String get contenuto => _contenuto;

  /// Squadriglia destinataria; `null` per tutta l'unità.
  String? get squadriglia => _squadriglia;

  /// Squadriglie attive dell'unità, più quella già scelta se nel frattempo
  /// è stata disattivata (così resta visibile e si può cambiare).
  List<String> get squadriglieDisponibili => _squadriglieDisponibili;

  /// Se il caricamento fallisce si può comunque scrivere a tutta l'unità.
  Future<void> _caricaSquadriglie() => eseguiCaricamento(() async {
        final squadriglie = await _scoutRepository.getSquadriglie();
        _squadriglieDisponibili = {
          ...squadriglie,
          ?_squadriglia,
        }.toList()
          ..sort();
      });

  /// Riprova a caricare le squadriglie (es. dopo un errore).
  Future<void> ricaricaSquadriglie() => _caricaSquadriglie();

  void setTitolo(String value) {
    _titolo = value;
    notifyListeners();
  }

  void setContenuto(String value) {
    _contenuto = value;
    notifyListeners();
  }

  /// Sceglie i destinatari: una squadriglia, o `null` per tutta l'unità.
  void setSquadriglia(String? value) {
    _squadriglia = value;
    notifyListeners();
  }

  bool get isValid => _titolo.trim().isNotEmpty && _contenuto.trim().isNotEmpty;

  /// Pubblica o aggiorna l'avviso (nessuna scrittura se il form non è valido).
  /// Un errore di salvataggio viene propagato alla View.
  Future<Avviso?> salva() async {
    if (!isValid) return null;

    final esistente = _avvisoEsistente;
    final avviso = Avviso(
      id: esistente?.id ?? '',
      titolo: _titolo.trim(),
      contenuto: _contenuto.trim(),
      dataPubblicazione: esistente?.dataPubblicazione ?? DateTime.now(),
      autore: esistente?.autore ?? '',
      squadriglia: _squadriglia,
      letto: true,
    );

    if (esistente != null) {
      await _avvisoRepository.aggiornaAvviso(avviso);
    } else {
      await _avvisoRepository.creaAvviso(avviso);
    }
    return avviso;
  }
}
