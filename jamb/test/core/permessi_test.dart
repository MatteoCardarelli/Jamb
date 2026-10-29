import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/permessi.dart';

/// Valori di `ruolo_enum` nell'ordine definito dall'ultima migrazione che lo crea.
List<String> _ruoliNelDatabase() {
  final definizione = RegExp(r'CREATE TYPE "public"\."ruolo_enum" AS ENUM \(([^)]*)\)');
  final migrazioni = Directory('../supabase/migrations')
      .listSync()
      .whereType<File>()
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final corpo = migrazioni
      .map((f) => definizione.firstMatch(f.readAsStringSync()))
      .whereType<RegExpMatch>()
      .last
      .group(1)!;
  return RegExp(r"'(\w+)'").allMatches(corpo).map((m) => m.group(1)!).toList();
}

void main() {
  group('Permessi', () {
    // L'aiuto capo opera sui ragazzi ma non può spostarli: senza questo
    // limite il salvataggio fallirebbe per intero, allergie comprese.
    test('l\'aiuto capo usa l\'area capi ma non cambia ruolo e squadriglia', () {
      const p = Permessi(ruolo: 'AIUTO_CAPO');
      expect(p.puoUsareAreaCapi, isTrue);
      expect(p.puoCambiareRuoloESquadriglia, isFalse);
    });

    test('il capo unità può cambiare ruolo e squadriglia', () {
      const p = Permessi(ruolo: 'CAPO_UNITA');
      expect(p.puoCambiareRuoloESquadriglia, isTrue);
    });

    // CAPO_SQ contiene "CAPO" ma è un ruolo da ragazzo.
    test('il capo squadriglia non accede all\'area capi', () {
      const p = Permessi(ruolo: 'CAPO_SQ');
      expect(p.puoUsareAreaCapi, isFalse);
    });

    // Come is_capo_gruppo() nelle policy: vale anche se nell'unità attiva
    // la sua membership ha un ruolo più basso.
    test('il capo gruppo ha ogni permesso anche con un ruolo minore nell\'unità', () {
      const p = Permessi(ruolo: 'AIUTO_CAPO', capoGruppo: true);
      expect(p.puoCambiareRuoloESquadriglia, isTrue);
    });

    test('un ruolo sconosciuto o assente non concede nulla', () {
      for (final p in const [Permessi(ruolo: 'SCONOSCIUTO'), Permessi.nessuno]) {
        expect(p.puoUsareAreaCapi, isFalse);
        expect(p.puoCambiareRuoloESquadriglia, isFalse);
      }
    });

    // Le policy confrontano i ruoli con >= secondo l'ordine dell'enum:
    // se il database cambia ordine o valori, l'app deve seguirlo.
    test('la gerarchia coincide con ruolo_enum del database', () {
      expect(gerarchiaRuoli, _ruoliNelDatabase());
    });
  });
}
