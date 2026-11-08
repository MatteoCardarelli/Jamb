import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';

const _aquile = Squadriglia(id: '1', nome: 'Aquile');
const _orsi = Squadriglia(id: '2', nome: 'Orsi', attiva: false);

MembroUnita _m(String nome, String ruolo, [String? squadriglia]) =>
    MembroUnita(id: nome, nome: nome, ruolo: ruolo, squadriglia: squadriglia);

void main() {
  group('consiglioCapi', () {
    test('staff, capi e vice delle squadriglie attive; non i ragazzi', () {
      final consiglio = consiglioCapi([
        _m('Zoe', 'CAPO_UNITA'),
        _m('Anna', 'CAPO_SQ', 'Aquile'),
        _m('Bruno', 'VICE_CAPO_SQ', 'Aquile'),
        _m('Carlo', 'RAGAZZO', 'Aquile'),
      ], [_aquile]);
      expect(consiglio.map((m) => m.nome), ['Anna', 'Bruno', 'Zoe']);
    });

    test('il capo di una squadriglia disattivata non ne fa parte', () {
      expect(consiglioCapi([_m('Anna', 'CAPO_SQ', 'Orsi')], [_orsi]), isEmpty);
    });

    test('un capo squadriglia senza squadriglia non ne fa parte', () {
      expect(consiglioCapi([_m('Anna', 'CAPO_SQ')], [_aquile]), isEmpty);
    });
  });

  group('erroreNomeSquadriglia', () {
    test('rifiuta un nome già usato, anche con maiuscole e spazi diversi', () {
      expect(erroreNomeSquadriglia('  aQUILE ', [_aquile]), isNotNull);
    });

    test('una squadriglia disattivata occupa il nome e lo dice', () {
      expect(erroreNomeSquadriglia('Orsi', [_orsi]), contains('riattivala'));
    });

    test('rinominando si può tenere il proprio nome', () {
      expect(erroreNomeSquadriglia('Aquile', [_aquile], escludiId: '1'), isNull);
    });

    test('rifiuta nomi vuoti o troppo lunghi', () {
      expect(erroreNomeSquadriglia('   ', const []), isNotNull);
      expect(erroreNomeSquadriglia('a' * 51, const []), isNotNull);
    });
  });

  group('SottogruppiBranca', () {
    test('E/G ha squadriglie, Consiglio Capi e Alta Squadriglia', () {
      final b = SottogruppiBranca.di('EG');
      expect(b.gruppi, 'Squadriglie');
      expect(b.consiglioCapi, isTrue);
      expect(b.scelti, [TipoSottogruppo.altaSquadriglia]);
    });

    test('L/C ha sestiglie e Consiglio della Rupe', () {
      final b = SottogruppiBranca.di('LC');
      expect(b.gruppi, 'Sestiglie');
      expect(b.consiglioCapi, isFalse);
      expect(b.scelti, [TipoSottogruppo.consiglioRupe]);
    });

    test('R/S e branche sconosciute non hanno sottogruppi', () {
      expect(SottogruppiBranca.di('RS').vuota, isTrue);
      expect(SottogruppiBranca.di(null).vuota, isTrue);
    });
  });

  test('i tipi dell\'app coincidono con il vincolo della migrazione', () {
    final migrazione = Directory('../supabase/migrations')
        .listSync()
        .whereType<File>()
        .singleWhere((f) => f.path.endsWith('_sottogruppi.sql'))
        .readAsStringSync();
    for (final t in TipoSottogruppo.values) {
      expect(migrazione, contains("'${t.valoreDb}'"));
    }
  });

  test('un valore sconosciuto del DB non diventa un tipo', () {
    expect(TipoSottogruppo.daDb('nuovo'), isNull);
  });
}
