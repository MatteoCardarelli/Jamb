import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/core/permessi.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/incarichi.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/assistente/view_model/assistenti_view_model.dart';
import '../../testing/fakes/fake_incarichi_repository.dart';

const _don = PersonaGruppo(id: 'd', nome: 'Don Paolo');
const _anna = PersonaGruppo(id: 'a', nome: 'Anna');

void main() {
  group('candidatiAssistente', () {
    test('esclude chi ha già l\'incarico e ordina per nome', () {
      const bruno = PersonaGruppo(id: 'b', nome: 'Bruno');
      expect(candidatiAssistente([bruno, _don, _anna], [_don]), [_anna, bruno]);
    });
  });

  group('AssistentiViewModel', () {
    test('la nomina sposta la persona tra gli assistenti', () async {
      final vm = AssistentiViewModel(FakeIncarichiRepository([_don, _anna]));
      await pumpEventQueue();
      expect(vm.assistenti, isEmpty);

      await vm.nomina(_don);
      await pumpEventQueue();

      expect(vm.assistenti, [_don]);
      expect(vm.candidati, [_anna]);
    });

    test('la revoca la riporta tra i candidati', () async {
      final vm = AssistentiViewModel(FakeIncarichiRepository([_don], assistenti: {'d'}));
      await pumpEventQueue();

      await vm.revoca(_don);
      await pumpEventQueue();

      expect(vm.assistenti, isEmpty);
      expect(vm.candidati, [_don]);
    });

    test('un errore di lettura diventa uno stato di errore', () async {
      final repo = FakeIncarichiRepository(const [])
        ..erroreLettura = const JambException(TipoErrore.rete, 'Nessuna connessione');
      final vm = AssistentiViewModel(repo);
      await pumpEventQueue();
      expect(vm.haErrore, isTrue);
    });
  });

  group('Permessi dell\'Assistente Ecclesiastico senza unità', () {
    const assistente = Permessi(assistenteEcclesiastico: true);

    test('non entra nell\'area dei capi', () {
      expect(assistente.puoUsareAreaCapi, isFalse);
    });

    // La policy lo ammette sull'unità COCA, non sui drive di branca.
    test('modifica il Drive di Co.Ca. ma non quello di Branca né le librerie', () {
      expect(assistente.puoModificare(ArchivioDocumenti.driveCoca), isTrue);
      expect(assistente.puoModificare(ArchivioDocumenti.driveBranca), isFalse);
      expect(assistente.puoModificare(ArchivioDocumenti.metodoStatuto), isFalse);
    });
  });

  group('Permessi.puoNominareAssistente', () {
    test('solo il Capo Gruppo', () {
      expect(const Permessi(ruolo: 'CAPO_UNITA').puoNominareAssistente, isFalse);
      expect(const Permessi(capoGruppo: true).puoNominareAssistente, isTrue);
    });
  });
}
