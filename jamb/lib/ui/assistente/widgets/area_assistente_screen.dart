import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/pillola.dart';
import 'package:jamb/ui/pillole/widgets/pillole_screen.dart';
import 'package:jamb/ui/veglie/widgets/veglie_screen.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_intestazione.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/explorer/widgets/explorer_screen.dart';
import 'package:jamb/ui/peg/widgets/peg_screen.dart';

/// Punto di partenza dell'Assistente Ecclesiastico che non ha un'unità: senza
/// unità attiva Home e sezioni dei capi sarebbero vuote.
class AreaAssistenteScreen extends StatelessWidget {
  const AreaAssistenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyBackgroundScreen(
      child: ListView(
        padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 40),
        children: [
          const JambIntestazione(titolo: 'Assistente Ecclesiastico'),
          const SizedBox(height: 24),
          JambPulsanteSecondario(
            icona: Icons.nightlight_outlined,
            etichetta: 'Veglie',
            onTap: () => VeglieScreen.apri(context),
          ),
          const SizedBox(height: 8),
          JambPulsanteSecondario(
            icona: Icons.auto_awesome_outlined,
            etichetta: 'Spunti di spiritualità',
            onTap: () => PilloleScreen.apri(context, tipo: TipoPillola.spiritualita),
          ),
          const SizedBox(height: 8),
          JambPulsanteSecondario(
            icona: Icons.explore_outlined,
            etichetta: 'Progetto Educativo di Gruppo',
            onTap: () => PegScreen.apri(context),
          ),
          const SizedBox(height: 8),
          JambPulsanteSecondario(
            icona: Icons.folder_shared_outlined,
            etichetta: ArchivioDocumenti.driveCoca.titolo,
            onTap: () => ExplorerScreen.apri(context, ArchivioDocumenti.driveCoca),
          ),
        ],
      ),
    );
  }
}
