import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/cache_letture.dart';

void main() {
  late DateTime ora;
  late CacheLetture cache;
  late int letture;

  Future<List<int>> leggi() async {
    letture++;
    return [letture];
  }

  setUp(() {
    ora = DateTime(2026, 11, 9, 12);
    letture = 0;
    cache = CacheLetture(durata: const Duration(minutes: 5), adesso: () => ora);
  });

  test('una seconda lettura non torna al server', () async {
    await cache.leggi('a', leggi);
    await cache.leggi('a', leggi);
    expect(letture, 1);
  });

  // All'avvio Home, Ragazzi e Amministrazione chiedono gli stessi dati insieme.
  test('letture contemporanee diventano una sola', () async {
    await Future.wait([cache.leggi('a', leggi), cache.leggi('a', leggi), cache.leggi('a', leggi)]);
    expect(letture, 1);
  });

  test('chiavi diverse sono letture diverse', () async {
    await cache.leggi('a', leggi);
    await cache.leggi('b', leggi);
    expect(letture, 2);
  });

  test('alla scadenza si rilegge', () async {
    await cache.leggi('a', leggi);
    ora = ora.add(const Duration(minutes: 4, seconds: 59));
    await cache.leggi('a', leggi);
    expect(letture, 1);
    ora = ora.add(const Duration(seconds: 1));
    await cache.leggi('a', leggi);
    expect(letture, 2);
  });

  test('una scrittura dimentica solo le chiavi che tocca', () async {
    await cache.leggi('campo_compiti/1', leggi);
    await cache.leggi('campo_contatti/1', leggi);
    cache.dimentica(['campo_compiti']);
    await cache.leggi('campo_compiti/1', leggi);
    await cache.leggi('campo_contatti/1', leggi);
    expect(letture, 3);
  });

  test('un errore non si memorizza', () async {
    await expectLater(cache.leggi<int>('a', () async => throw StateError('rete')), throwsStateError);
    expect(await cache.leggi('a', () async => 7), 7);
  });

  // Altrimenti, dopo il salvataggio, tornerebbe il dato vecchio.
  test('una lettura in corso durante una scrittura non viene riusata', () async {
    final inCorso = Completer<int>();
    final prima = cache.leggi('a', () => inCorso.future);
    cache.dimentica(['a']);
    expect(await cache.leggi('a', () async => 2), 2);
    inCorso.complete(1);
    await prima;
    expect(await cache.leggi('a', () async => 3), 2);
  });

  test('l\'errore di una lettura superata non cancella quella nuova', () async {
    final inCorso = Completer<int>();
    final prima = cache.leggi('a', () => inCorso.future);
    cache.dimentica(['a']);
    await cache.leggi('a', () async => 2);
    inCorso.completeError(StateError('rete'));
    await expectLater(prima, throwsStateError);
    expect(await cache.leggi('a', () async => 3), 2);
  });

  // I ViewModel ordinano la lista ricevuta.
  test('modificare la lista ricevuta non tocca quella memorizzata', () async {
    final prima = await cache.leggi('a', () async => [1, 2]);
    prima.clear();
    expect(await cache.leggi('a', () async => <int>[]), [1, 2]);
  });

  test('la copia mantiene il tipo della lista', () async {
    final lista = await cache.leggi<List<String>>('a', () async => ['x']);
    expect(lista, isA<List<String>>());
  });
}
