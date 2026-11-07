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

  Documento doc(String id, {String? padre, bool cartella = false, String? nome}) => Documento(
        id: id,
        nome: nome ?? id,
        tipo: cartella ? TipoDocumento.cartella : TipoDocumento.pdf,
        parentId: padre,
        ultimaModifica: DateTime(2026, 11, 7),
      );

  test('ordina prima le cartelle, poi i file, senza badare alle maiuscole', () {
    final ordinati = ordinaDocumenti([
      doc('zeta.pdf'),
      doc('Verbali', cartella: true),
      doc('alfa.pdf'),
      doc('archivio', cartella: true),
    ]);
    expect(ordinati.map((d) => d.id), ['archivio', 'Verbali', 'alfa.pdf', 'zeta.pdf']);
  });

  group('discendenti', () {
    final albero = [
      doc('uscite', cartella: true),
      doc('campo', padre: 'uscite', cartella: true),
      doc('menu.pdf', padre: 'campo'),
      doc('permessi.pdf', padre: 'uscite'),
      doc('verbali', cartella: true),
      doc('verbale.pdf', padre: 'verbali'),
    ];

    // Eliminando «uscite» vanno tolti dallo storage anche i file delle sottocartelle.
    test('trova i documenti a qualunque profondità', () {
      expect(discendenti(albero, 'uscite').map((d) => d.id).toSet(),
          {'campo', 'menu.pdf', 'permessi.pdf'});
    });

    test('non include le cartelle accanto', () {
      expect(discendenti(albero, 'campo').map((d) => d.id), ['menu.pdf']);
    });

    test('un ciclo nei dati non blocca la ricerca', () {
      final ciclo = [doc('a', padre: 'b', cartella: true), doc('b', padre: 'a', cartella: true)];
      expect(discendenti(ciclo, 'a').map((d) => d.id).toSet(), {'b', 'a'});
    });
  });

  test('i formati simili condividono il tipo', () {
    expect(TipoDocumento.daEstensione('docx'), TipoDocumento.doc);
    expect(TipoDocumento.daEstensione('heic'), TipoDocumento.jpeg);
    expect(TipoDocumento.daEstensione('ods'), TipoDocumento.xls);
    expect(TipoDocumento.daEstensione('sconosciuta'), TipoDocumento.txt);
  });
}
