import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamb/data/services/file_archiviati.dart';
import 'package:jamb/domain/entities/anno_scout.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/core/pdf_jamb.dart';
import 'package:jamb/ui/verifica_obiettivi/view_model/verifica_obiettivi_view_model.dart';
import '../../testing/fakes/fake_documento_repository.dart';

const _obiettivo = Obiettivo(
  id: '1',
  dominio: 'Servizio',
  descrizione: 'Ogni squadriglia organizza un servizio al quartiere',
  grado: 3,
  colore: Colors.teal,
  icona: Icons.handshake,
  diarioDiBordo: 'Raccolta alimentare a ottobre.',
);

void main() {
  group('annoScoutDi', () {
    // L'anno scout cambia il 1° settembre, non il 1° gennaio.
    test('cambia il 1° settembre', () {
      expect(annoScoutDi(DateTime(2026, 8, 31)), '2025-2026');
      expect(annoScoutDi(DateTime(2026, 9, 1)), '2026-2027');
      expect(annoScoutDi(DateTime(2027, 1, 15)), '2026-2027');
    });
  });

  group('VerificaObiettiviViewModel.archiviaNelDrive', () {
    final oggi = DateTime(2026, 11, 7);

    test('carica un PDF con anno scout e data nella radice del Drive di Branca', () async {
      final repo = FakeDocumentoRepository();
      final vm = VerificaObiettiviViewModel([_obiettivo], repo);

      await vm.archiviaNelDrive(unita: 'Reparto Velino', oggi: oggi);

      final file = repo.caricati.single;
      expect(file.nome, "Programma d'Unità 2026-2027 - 07-11-2026.pdf");
      expect(ascii.decode(file.byte.sublist(0, 5)), '%PDF-');
      expect(repo.archivi[ArchivioDocumenti.driveBranca]!.single.parentId, isNull);
    });

    // Il nome deve superare le stesse regole di un nome scritto a mano,
    // e il tipo dev'essere tra quelli ammessi dal bucket.
    test('il nome del file è valido e ammesso dall\'archivio', () {
      final nome = VerificaObiettiviViewModel.nomeFileProgramma(oggi);
      expect(erroreNomeDocumento(nome), isNull);
      expect(mimeDocumenti[estensioneDi(nome)], 'application/pdf');
    });

    // Le tastiere dei telefoni inseriscono apostrofi tipografici: nel PDF
    // sparirebbero ("L uscita") perché il font base non li ha.
    test('la punteggiatura tipografica diventa quella semplice', () {
      expect(testoPerPdf('L’uscita “bella” – 3…'), 'L\'uscita "bella" - 3...');
    });

    test('un Programma vuoto produce comunque un PDF', () async {
      final repo = FakeDocumentoRepository();
      await VerificaObiettiviViewModel(const [], repo).archiviaNelDrive(unita: 'Reparto', oggi: oggi);
      expect(repo.caricati.single.byte, isNotEmpty);
    });
  });
}
