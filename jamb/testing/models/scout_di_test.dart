import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/entities/progresso.dart';

/// Crea uno [Scout] di test con valori di default sovrascrivibili.
Scout scoutDiTest(
  String nome,
  String squadriglia, {
  String? allergie,
  DocumentoStatus cens = DocumentoStatus.valido,
  DocumentoStatus priv = DocumentoStatus.valido,
  DocumentoStatus med = DocumentoStatus.valido,
}) {
  return Scout(
    id: nome,
    nome: nome,
    squadriglia: squadriglia,
    ruolo: 'RAGAZZO',
    progresso: const ProgressoScout(),
    allergie: allergie,
    statoCensimento: cens,
    statoPrivacy: priv,
    statoMedica: med,
  );
}