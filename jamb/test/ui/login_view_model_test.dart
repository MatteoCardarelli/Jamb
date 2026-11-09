import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';
import 'package:jamb/ui/auth/view_model/login_view_model.dart';

import '../../testing/fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late LoginViewModel viewModel;

  setUp(() {
    repository = FakeAuthRepository();
    viewModel = LoginViewModel(repository);
  });

  test('toglie gli spazi dall\'email incollata', () async {
    await viewModel.login('  capo@test.it ', 'x');
    expect(repository.emailRicevuta, 'capo@test.it');
    expect(viewModel.errorMessage, isNull);
  });

  test('mostra il motivo del rifiuto e torna utilizzabile', () async {
    repository.errore = const JambException(TipoErrore.nonAutenticato, 'Credenziali errate');
    await viewModel.login('capo@test.it', 'x');
    expect(viewModel.errorMessage, 'Credenziali errate');
    expect(viewModel.isLoading, isFalse);
  });

  test('un nuovo tentativo cancella l\'errore precedente', () async {
    repository.errore = const JambException(TipoErrore.rete, 'Niente rete');
    await viewModel.login('capo@test.it', 'x');
    repository.errore = null;
    await viewModel.login('capo@test.it', 'x');
    expect(viewModel.errorMessage, isNull);
  });
}
