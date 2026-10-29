import 'package:jamb/domain/entities/avviso.dart';

/// Crea un [Avviso] di test pubblicato il [giorno] di ottobre 2026.
Avviso avvisoDiTest(
  String id, {
  int giorno = 1,
  String? squadriglia,
  bool letto = false,
}) {
  return Avviso(
    id: id,
    titolo: id,
    contenuto: 'Testo di $id',
    dataPubblicazione: DateTime(2026, 10, giorno),
    squadriglia: squadriglia,
    letto: letto,
  );
}
