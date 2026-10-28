import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/repositories/supabase_scout_repository.dart';
import 'package:jamb/domain/entities/progresso.dart';
import '../../testing/models/scout_di_test.dart';

/// Ultima migrazione che definisce la funzione SQL `salva_ragazzo`.
String _sqlSalvaRagazzo() {
  final migrazioni = Directory('../supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.readAsStringSync().contains('FUNCTION "public"."salva_ragazzo"'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return migrazioni.last.readAsStringSync();
}

void main() {
  group('SupabaseScoutRepository.payloadRagazzo', () {
    // Il payload è il contratto con la funzione SQL: una chiave mancante non
    // dà errore, diventa NULL nel database (es. uno stato documentale perso).
    test('contiene ogni chiave letta dalla funzione salva_ragazzo', () {
      final sql = _sqlSalvaRagazzo();
      final chiaviLette = {
        ...RegExp(r"p_ragazzo->>?'(\w+)'").allMatches(sql).map((m) => m.group(1)!),
        ...RegExp(r"p_ragazzo#>>?'\{(\w+),").allMatches(sql).map((m) => m.group(1)!),
      };
      expect(chiaviLette, isNotEmpty);

      final payload = SupabaseScoutRepository.payloadRagazzo(scoutDiTest('Andrea', 'Aquile'));
      expect(payload.keys, containsAll(chiaviLette));
    });

    test('le date sono nel formato AAAA-MM-GG richiesto dalle colonne date', () {
      final scout = scoutDiTest('Andrea', 'Aquile').copyWith(
        scadenzaPrivacy: DateTime(2027, 3, 9, 15, 30),
        progresso: ProgressoScout(specialita: [
          Specialita(
            nome: SpecialitaNome.values.first,
            prove: const [],
            dataConseguimento: DateTime(2026, 11, 2, 8),
          ),
        ]),
      );

      final payload = SupabaseScoutRepository.payloadRagazzo(scout);
      expect(payload['scadenza_privacy'], '2027-03-09');
      expect((payload['specialita'] as List).single['data_conseguimento'], '2026-11-02');
    });
  });
}
