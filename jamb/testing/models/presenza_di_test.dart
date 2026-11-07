import 'package:jamb/domain/entities/presenza.dart';

/// Crea una [PresenzaRagazzo] di test a un evento del [giorno] di ottobre 2026.
PresenzaRagazzo presenzaDiTest(int giorno, StatoPresenza stato) {
  return PresenzaRagazzo(
    eventoId: 'evento-$giorno',
    titoloEvento: 'Riunione del $giorno',
    dataEvento: DateTime(2026, 10, giorno, 15),
    stato: stato,
  );
}
