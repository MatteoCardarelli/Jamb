import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/entities/progresso.dart';

void main() {
  group('Scout.iniziali', () {
    test('usa prima e ultima parola del nome', () {
      final s = Scout(
        id: '1', nome: 'Andrea Conti', squadriglia: 'Aquile',
        ruolo: 'RAGAZZO', progresso: const ProgressoScout(),
      );
      expect(s.iniziali, 'AC');
    });

    test('con un solo nome usa la prima lettera', () {
      final s = Scout(
        id: '1', nome: 'Andrea', squadriglia: 'Aquile',
        ruolo: 'RAGAZZO', progresso: const ProgressoScout(),
      );
      expect(s.iniziali, 'A');
    });
  });

  group('DocumentoStatus.safeByName', () {
    test('riconosce un nome valido', () {
      expect(DocumentoStatus.safeByName('valido'), DocumentoStatus.valido);
    });
    test('un nome sconosciuto diventa nessuno', () {
      expect(DocumentoStatus.safeByName('xyz'), DocumentoStatus.nessuno);
    });
  });
}