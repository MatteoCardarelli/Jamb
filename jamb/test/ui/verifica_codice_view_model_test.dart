import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/auth/view_model/verifica_codice_view_model.dart';

import '../../testing/fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late VerificaCodiceViewModel viewModel;

  setUp(() {
    repository = FakeAuthRepository();
    viewModel = VerificaCodiceViewModel(repository);
  });

  test('un codice che non è di 6 cifre non arriva al server', () async {
    await viewModel.verifica('12345');
    expect(viewModel.errorMessage, erroreCodiceSeiCifre);
    expect(repository.codiciRicevuti, isEmpty);
  });

  test('il codice incollato con uno spazio viene accettato', () async {
    await viewModel.verifica('123 456');
    expect(repository.codiciRicevuti, ['123456']);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('un codice sbagliato mostra il motivo e si può riprovare', () async {
    await viewModel.verifica('654321');
    expect(viewModel.errorMessage, 'Codice non valido');
    expect(viewModel.isLoading, isFalse);

    await viewModel.verifica('123456');
    expect(viewModel.errorMessage, isNull);
  });

  test('senza rete lo dice, invece di dare il codice per sbagliato', () async {
    repository.errore = const JambException(TipoErrore.rete, 'Niente rete');
    await viewModel.verifica('123456');
    expect(viewModel.errorMessage, 'Niente rete');
  });
}
