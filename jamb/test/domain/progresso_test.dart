import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/progresso.dart';

void main() {
  group('Specialita.isPosseduta', () {
    test('vera se tutte le prove sono completate e c\'è la data', () {
      final s = Specialita(
        nome: SpecialitaNome.Cuoco,
        prove: [const Impegno(titolo: 'p1', isCompletato: true)],
        dataConseguimento: DateTime(2026, 1, 1),
      );
      expect(s.isPosseduta, true);
    });

    test('falsa se una prova non è completata', () {
      final s = Specialita(
        nome: SpecialitaNome.Cuoco,
        prove: [const Impegno(titolo: 'p1', isCompletato: false)],
        dataConseguimento: DateTime(2026, 1, 1),
      );
      expect(s.isPosseduta, false);
    });
  });

  group('Specialita.fromMap', () {
    // I 67 nomi delle specialità sono dichiarati due volte, come enum in
    // PostgreSQL e come enum in Dart: se le due dichiarazioni divergono,
    // la riga sconosciuta va scartata senza far fallire l'intera scheda.
    test('scarta una specialità con nome non riconosciuto', () {
      final s = Specialita.fromMap({
        'nome': 'SpecialitaInesistente',
        'prove': [],
        'dataConseguimento': null,
      });
      expect(s, isNull);
    });
  });
}