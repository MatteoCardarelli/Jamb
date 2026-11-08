/// Preferenze dell'utente sull'aspetto della Home (US3).
class Preferenze {
  final bool mostraPillole;
  final bool mostraCassa;

  const Preferenze({this.mostraPillole = true, this.mostraCassa = true});

  Preferenze copyWith({bool? mostraPillole, bool? mostraCassa}) => Preferenze(
        mostraPillole: mostraPillole ?? this.mostraPillole,
        mostraCassa: mostraCassa ?? this.mostraCassa,
      );
}

/// Contratto per le preferenze dell'utente, conservate sul dispositivo.
abstract class IPreferenzeRepository {
  /// Preferenze salvate; quelle predefinite se non ce ne sono.
  Future<Preferenze> leggi();

  /// Salva le [preferenze].
  Future<void> salva(Preferenze preferenze);
}
