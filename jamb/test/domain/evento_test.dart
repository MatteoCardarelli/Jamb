import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/evento.dart';

void main() {
  group('CategoriaEvento.fromString', () {
    test('match case-insensitive', () {
      expect(CategoriaEvento.fromString('spiritualità'), CategoriaEvento.spiritualita);
    });
    test('valore sconosciuto diventa altro', () {
      expect(CategoriaEvento.fromString('boh'), CategoriaEvento.altro);
    });
  });
}