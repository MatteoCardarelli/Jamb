import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/auth/view_model/verifica_codice_view_model.dart';
import 'package:jamb/ui/profilo/view_model/attiva_due_fattori_view_model.dart';
import 'package:jamb/ui/profilo/view_model/sicurezza_view_model.dart';

import '../../testing/fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  group('SicurezzaViewModel', () {
    test('legge se la verifica è attiva', () async {
      repository.dueFattori = true;
      final vm = SicurezzaViewModel(repository);
      await pumpEventQueue();
      expect(vm.dueFattori, isTrue);
      expect(vm.haErrore, isFalse);
    });

    test('senza rete mostra l\'errore, non «disattiva»', () async {
      repository.dueFattori = true;
      repository.errore = const JambException(TipoErrore.rete, 'Niente rete');
      final vm = SicurezzaViewModel(repository);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
      expect(vm.errore, 'Niente rete');
    });

    test('disattivare aggiorna lo stato', () async {
      repository.dueFattori = true;
      final vm = SicurezzaViewModel(repository);
      await pumpEventQueue();
      await vm.disattiva();
      expect(vm.dueFattori, isFalse);
      expect(repository.dueFattori, isFalse);
    });

    test('se la disattivazione fallisce resta attiva', () async {
      repository.dueFattori = true;
      final vm = SicurezzaViewModel(repository);
      await pumpEventQueue();
      repository.errore = const JambException(TipoErrore.rete, 'Niente rete');
      await expectLater(vm.disattiva(), throwsA(isA<JambException>()));
      expect(vm.dueFattori, isTrue);
    });
  });

  group('AttivaDueFattoriViewModel', () {
    test('prepara subito il codice QR', () async {
      final vm = AttivaDueFattoriViewModel(repository);
      await pumpEventQueue();
      expect(vm.attivazione, FakeAuthRepository.attivazione);
      expect(repository.preparazioni, 1);
    });

    test('un codice malformato non arriva al server', () async {
      final vm = AttivaDueFattoriViewModel(repository);
      await pumpEventQueue();
      await expectLater(
        vm.conferma('12 34'),
        throwsA(
          isA<JambException>().having(
            (e) => e.messaggio,
            'messaggio',
            erroreCodiceSeiCifre,
          ),
        ),
      );
      expect(repository.codiciRicevuti, isEmpty);
      expect(repository.dueFattori, isFalse);
    });

    test('un codice sbagliato non attiva; quello giusto sì', () async {
      final vm = AttivaDueFattoriViewModel(repository);
      await pumpEventQueue();
      await expectLater(vm.conferma('000000'), throwsA(isA<JambException>()));
      expect(repository.dueFattori, isFalse);

      await vm.conferma('123456');
      expect(repository.dueFattori, isTrue);
    });

    test(
      'se la preparazione fallisce, «Riprova» ne prepara una nuova',
      () async {
        repository.errore = const JambException(TipoErrore.rete, 'Niente rete');
        final vm = AttivaDueFattoriViewModel(repository);
        await pumpEventQueue();
        expect(vm.haErrore, isTrue);
        expect(vm.attivazione, isNull);

        repository.errore = null;
        await vm.prepara();
        expect(vm.attivazione, isNotNull);
        expect(vm.haErrore, isFalse);
      },
    );
  });
}
