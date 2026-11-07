import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/documento.dart';

void main() {
  group('erroreNomeDocumento', () {
    test('accetta un nome normale, anche con spazi intorno', () {
      expect(erroreNomeDocumento('  Verbali 2026  '), isNull);
    });

    test('rifiuta un nome vuoto o di soli spazi', () {
      expect(erroreNomeDocumento('   '), isNotNull);
    });

    // La barra separerebbe le cartelle nei percorsi e confonderebbe i nomi.
    test('rifiuta le barre', () {
      expect(erroreNomeDocumento('Uscite/Campo'), isNotNull);
      expect(erroreNomeDocumento(r'Uscite\Campo'), isNotNull);
    });

    test('rifiuta un nome oltre la lunghezza della colonna', () {
      expect(erroreNomeDocumento('a' * lunghezzaMassimaNomeDocumento), isNull);
      expect(erroreNomeDocumento('a' * (lunghezzaMassimaNomeDocumento + 1)), isNotNull);
    });
  });

  test('i formati simili condividono il tipo', () {
    expect(TipoDocumento.daEstensione('docx'), TipoDocumento.doc);
    expect(TipoDocumento.daEstensione('heic'), TipoDocumento.jpeg);
    expect(TipoDocumento.daEstensione('ods'), TipoDocumento.xls);
    expect(TipoDocumento.daEstensione('sconosciuta'), TipoDocumento.txt);
  });
}
