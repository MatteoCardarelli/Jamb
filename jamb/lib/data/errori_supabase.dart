import 'dart:async';

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';

/// Scrittura tentata senza un utente autenticato.
const sessioneSenzaUtente = JambException(
  TipoErrore.nonAutenticato,
  'Sessione scaduta. Accedi di nuovo.',
);

/// Scrittura tentata senza un'unità attiva in cui operare.
const sessioneSenzaUnita = JambException(
  TipoErrore.nonAutenticato,
  'Nessuna unità attiva: impossibile salvare.',
);

/// Esegue un'operazione verso Supabase traducendo ogni errore in una
/// [JambException], senza perdere lo stack trace originale.
Future<T> eseguiSupabase<T>(Future<T> Function() operazione) async {
  try {
    return await operazione();
  } catch (e, stackTrace) {
    Error.throwWithStackTrace(traduciErrore(e), stackTrace);
  }
}

/// Traduce un'eccezione di Supabase, della rete o del runtime in una
/// [JambException] con un messaggio comprensibile per l'utente.
JambException traduciErrore(Object errore) {
  if (errore is JambException) return errore;

  // http incapsula gli errori di socket in ClientException.
  if (errore is ClientException ||
      errore is TimeoutException ||
      errore is AuthRetryableFetchException) {
    return JambException(
      TipoErrore.rete,
      'Connessione assente. Controlla la rete e riprova.',
      causa: errore,
    );
  }

  if (errore is AuthException) {
    return JambException(
      TipoErrore.nonAutenticato,
      'Sessione scaduta. Accedi di nuovo.',
      causa: errore,
    );
  }

  if (errore is PostgrestException) return _traduciPostgrest(errore);

  return JambException(
    TipoErrore.sconosciuto,
    'Si è verificato un errore imprevisto.',
    causa: errore,
  );
}

/// Codici SQLSTATE di PostgreSQL e codici PostgREST (`PGRST…`).
JambException _traduciPostgrest(PostgrestException e) {
  switch (e.code) {
    case '42501': // insufficient_privilege: policy RLS violata
      return JambException(
        TipoErrore.permessoNegato,
        'Non hai i permessi per questa operazione.',
        causa: e,
      );
    case 'PGRST301': // JWT scaduto o non valido
    case 'PGRST302': // autenticazione mancante
      return JambException(
        TipoErrore.nonAutenticato,
        'Sessione scaduta. Accedi di nuovo.',
        causa: e,
      );
    case '23505': // unique_violation
      return JambException(
        TipoErrore.conflitto,
        'Esiste già un elemento con questi dati.',
        causa: e,
      );
    case '23503': // foreign_key_violation
      return JambException(
        TipoErrore.conflitto,
        'Operazione non possibile: il dato è collegato ad altri elementi.',
        causa: e,
      );
    case '23502': // not_null_violation
    case '23514': // check_violation
    case '22P02': // invalid_text_representation (es. valore di enum sconosciuto)
      return JambException(
        TipoErrore.datiNonValidi,
        'Alcuni dati non sono validi.',
        causa: e,
      );
    default:
      return JambException(
        TipoErrore.sconosciuto,
        'Il server ha rifiutato l\'operazione.',
        causa: e,
      );
  }
}
