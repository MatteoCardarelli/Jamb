import 'package:jamb/domain/entities/transazione.dart';

/// Crea una [Transazione] di test.
Transazione transazioneDiTest(
  String id,
  double importo,
  bool isUscita,
  Categoria categoria,
) {
  return Transazione(
    id: id,
    titolo: id,
    importo: importo,
    isUscita: isUscita,
    categoria: categoria,
    data: DateTime(2026, 1, 1),
  );
}