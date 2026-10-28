import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('traduciErrore', () {
    // Una policy RLS violata arriva come 42501: va distinta da un errore
    // generico, altrimenti l'utente non capisce di non avere i permessi.
    test('una violazione RLS diventa permessoNegato', () {
      final e = traduciErrore(const PostgrestException(
        message: 'new row violates row-level security policy',
        code: '42501',
      ));
      expect(e.tipo, TipoErrore.permessoNegato);
    });

    test('un errore di rete del client http diventa rete', () {
      final e = traduciErrore(ClientException('Connection failed'));
      expect(e.tipo, TipoErrore.rete);
    });

    test('un codice PostgREST non previsto diventa sconosciuto', () {
      final e = traduciErrore(const PostgrestException(message: '?', code: 'XX000'));
      expect(e.tipo, TipoErrore.sconosciuto);
    });

    // Le JambException sollevate dai repository (es. sessione senza unità)
    // non devono perdere il loro messaggio passando dalla traduzione.
    test('una JambException passa invariata', () {
      expect(traduciErrore(sessioneSenzaUnita), same(sessioneSenzaUnita));
    });
  });

  test('eseguiSupabase solleva solo JambException', () async {
    await expectLater(
      eseguiSupabase<void>(() async => throw ClientException('offline')),
      throwsA(isA<JambException>()
          .having((e) => e.tipo, 'tipo', TipoErrore.rete)),
    );
  });
}
