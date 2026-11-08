import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/repositories/supabase_evento_repository.dart';
import 'package:jamb/domain/entities/evento.dart';

/// Valori ammessi da `events_ripetizione_check`, letti dalla migrazione.
Set<String> _ripetizioniNelDatabase() {
  final testo = File('../supabase/migrations/20261108001647_eventi_ripetuti.sql').readAsStringSync();
  final elenco = RegExp(r'"ripetizione" IN \(([^)]*)\)').firstMatch(testo)!.group(1)!;
  return RegExp(r"'(\w+)'").allMatches(elenco).map((m) => m.group(1)!).toSet();
}

void main() {
  // Un valore non ammesso dal vincolo farebbe fallire la creazione di ogni
  // serie, ma solo sul telefono.
  test('ogni ripetizione ha un valore ammesso da events.ripetizione', () {
    final ammessi = _ripetizioniNelDatabase();
    for (final r in Ripetizione.values.where((r) => r != Ripetizione.mai)) {
      final valore = SupabaseEventoRepository.valoreDbRipetizione(r);
      expect(ammessi, contains(valore));
      expect(SupabaseEventoRepository.ripetizioneDaDb(valore), r);
    }
  });

  test('un evento singolo non ha ripetizione nel database', () {
    expect(SupabaseEventoRepository.valoreDbRipetizione(Ripetizione.mai), isNull);
    expect(SupabaseEventoRepository.ripetizioneDaDb(null), Ripetizione.mai);
    expect(SupabaseEventoRepository.ripetizioneDaDb('ogni_tanto'), Ripetizione.mai);
  });
}
