/// Categoria di un errore, indipendente dalla sorgente dati che l'ha prodotto.
enum TipoErrore {
  /// Rete assente o server non raggiungibile.
  rete,

  /// Sessione mancante o scaduta: serve un nuovo accesso.
  nonAutenticato,

  /// Operazione negata dalle policy di sicurezza (RLS).
  permessoNegato,

  /// Il dato esiste già o è collegato ad altri dati.
  conflitto,

  /// Il dato inviato non rispetta i vincoli del database.
  datiNonValidi,

  /// Qualsiasi altro errore.
  sconosciuto,
}

/// Errore di dominio sollevato dai repository.
///
/// I livelli UI e ViewModel conoscono solo questa eccezione: non dipendono
/// dalle eccezioni specifiche di Supabase o della rete.
class JambException implements Exception {
  final TipoErrore tipo;

  /// Messaggio in italiano, pronto da mostrare all'utente.
  final String messaggio;

  /// Eccezione originale, conservata per il debug.
  final Object? causa;

  const JambException(this.tipo, this.messaggio, {this.causa});

  /// Messaggio da mostrare all'utente per un errore qualsiasi [errore].
  static String messaggioPer(Object errore) => errore is JambException
      ? errore.messaggio
      : 'Si è verificato un errore imprevisto.';

  @override
  String toString() =>
      'JambException(${tipo.name}): $messaggio${causa != null ? ' [$causa]' : ''}';
}
