import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_intestazione.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/explorer/widgets/explorer_screen.dart';

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
            icona: Icons.folder_shared_outlined,
            etichetta: ArchivioDocumenti.driveCoca.titolo,
            onTap: () => ExplorerScreen.apri(context, ArchivioDocumenti.driveCoca),
          ),
        ],
      ),
    );
  }
}
