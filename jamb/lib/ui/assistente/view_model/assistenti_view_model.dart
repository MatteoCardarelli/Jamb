import 'package:flutter/foundation.dart';
import 'package:jamb/domain/entities/incarichi.dart';
import 'package:jamb/domain/repositories/incarichi_repository.dart';
import 'package:jamb/ui/core/view_model/stato_caricamento.dart';

/// Nomina e revoca dell'Assistente Ecclesiastico da parte del Capo Gruppo.
class AssistentiViewModel extends ChangeNotifier with StatoCaricamentoMixin {
  final IIncarichiRepository _repository;

  List<PersonaGruppo> _assistenti = const [];
  List<PersonaGruppo> _persone = const [];

  AssistentiViewModel(this._repository) {
    _repository.addListener(_carica);
    _carica();
  }

  @override
  void dispose() {
    _repository.removeListener(_carica);
    super.dispose();
  }

  Future<void> _carica() => eseguiCaricamento(() async {
        _assistenti = await _repository.getAssistenti();
        _persone = await _repository.getPersone();
      });

  /// Rilegge i dati (es. dopo un errore).
  Future<void> ricarica() => _carica();

  List<PersonaGruppo> get assistenti => _assistenti;

  /// Persone che si possono nominare.
  List<PersonaGruppo> get candidati => candidatiAssistente(_persone, _assistenti);

  /// Nomina [persona]. Un errore viene propagato alla View.
  Future<void> nomina(PersonaGruppo persona) => _repository.nomina(persona.id);

  /// Toglie l'incarico a [persona].
  Future<void> revoca(PersonaGruppo persona) => _repository.revoca(persona.id);
}
