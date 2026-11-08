import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/entities/badge.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/domain/repositories/preferenze_repository.dart';
import 'package:jamb/ui/profilo/view_model/preferenze_view_model.dart';
import 'package:jamb/ui/profilo/view_model/profilo_view_model.dart';
import 'package:jamb/ui/profilo/widgets/sezioni_formazione.dart';
import '../../testing/fakes/fake_formazione_repository.dart';

IncaricoStorico _i(String ruolo, String anno, [String? branca = 'EG']) =>
    IncaricoStorico(ruolo: ruolo, annoScout: anno, tipoBranca: branca);

class _PreferenzeInMemoria implements IPreferenzeRepository {
  Preferenze salvate;
  bool fallisce = false;
  _PreferenzeInMemoria([this.salvate = const Preferenze()]);

  @override
  Future<Preferenze> leggi() async => salvate;

  @override
  Future<void> salva(Preferenze p) async {
    if (fallisce) throw const JambException(TipoErrore.rete, 'Errore');
    salvate = p;
  }
}

List<String> _titoli(Iterable<IncaricoStorico> storico) =>
    badgeDaStorico(storico).map((b) => b.titolo).toList();

void main() {
  group('badgeDaStorico', () {
    test('uno storico vuoto non dà badge', () {
      expect(badgeDaStorico(const []), isEmpty);
    });

    // Gli anni da ragazzo non sono servizio da capo.
    test('gli anni da ragazzo non contano', () {
      expect(_titoli([_i('RAGAZZO', '2020-2021'), _i('CAPO_SQ', '2021-2022')]), isEmpty);
    });

    test('più membership nello stesso anno contano una volta', () {
      expect(
        _titoli([_i('AIUTO_CAPO', '2025-2026'), _i('AIUTO_CAPO', '2025-2026', 'LC')]).first,
        '1 anno di servizio',
      );
    });

    test('mostra solo la soglia più alta raggiunta', () {
      final anni = [for (var a = 2020; a < 2025; a++) _i('AIUTO_CAPO', '$a-${a + 1}')];
      final titoli = _titoli(anni);
      expect(titoli, contains('5 anni di servizio'));
      expect(titoli, isNot(contains('3 anni di servizio')));
    });

    test('due anni restano alla soglia di uno', () {
      expect(
        _titoli([_i('AIUTO_CAPO', '2024-2025'), _i('AIUTO_CAPO', '2025-2026')]),
        ['1 anno di servizio'],
      );
    });

    test('un incarico ricoperto in passato resta come badge', () {
      expect(_titoli([_i('CAPO_UNITA', '2020-2021')]), contains('Capo Unità'));
    });

    test('la Co.Ca. non conta come branca di servizio', () {
      expect(
        _titoli([_i('AIUTO_CAPO', '2024-2025'), _i('AIUTO_CAPO', '2025-2026', 'COCA')]),
        isNot(contains('Servizio in 2 branche')),
      );
    });

    test('due branche danno il badge', () {
      expect(
        _titoli([_i('AIUTO_CAPO', '2024-2025', 'LC'), _i('AIUTO_CAPO', '2025-2026', 'EG')]),
        contains('Servizio in 2 branche'),
      );
    });
  });

  test('ProfiloViewModel ricava i badge dallo storico', () async {
    final repo = FakeFormazioneRepository()..storico = [_i('CAPO_GRUPPO', '2025-2026')];
    final vm = ProfiloViewModel(repo);
    await pumpEventQueue();
    expect(vm.badge.map((b) => b.tipo), contains(TipoBadge.capoGruppo));
  });

  group('PreferenzeViewModel', () {
    test('legge quelle salvate', () async {
      final vm = PreferenzeViewModel(_PreferenzeInMemoria(const Preferenze(mostraCassa: false)));
      await pumpEventQueue();
      expect(vm.mostraCassa, isFalse);
      expect(vm.mostraPillole, isTrue);
    });

    test('cambiare una preferenza non tocca l\'altra', () async {
      final repo = _PreferenzeInMemoria(const Preferenze(mostraCassa: false));
      final vm = PreferenzeViewModel(repo);
      await pumpEventQueue();
      await vm.setMostraPillole(false);
      expect(repo.salvate.mostraPillole, isFalse);
      expect(repo.salvate.mostraCassa, isFalse);
    });

    test('se il salvataggio fallisce torna la scelta di prima', () async {
      final repo = _PreferenzeInMemoria()..fallisce = true;
      final vm = PreferenzeViewModel(repo);
      await pumpEventQueue();
      await expectLater(vm.setMostraPillole(false), throwsA(isA<JambException>()));
      expect(vm.mostraPillole, isTrue);
    });
  });

  testWidgets('RiquadroBadge senza badge lo dice', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RiquadroBadge(badge: []))));
    expect(find.text('Ancora nessun badge.'), findsOneWidget);
  });
}
