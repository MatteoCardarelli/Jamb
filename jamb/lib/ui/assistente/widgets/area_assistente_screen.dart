import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_intestazione.dart';
import 'package:jamb/ui/core/widgets/jamb_lavori_in_corso.dart';

/// Punto di partenza dell'Assistente Ecclesiastico che non ha un'unità: senza
/// unità attiva Home e sezioni dei capi sarebbero vuote.
///
/// Per ora mostra «lavori in corso» (l'utente, 2026-11-15: la parte
/// dell'Assistente va rifatta). Le schermate che conteneva (veglie, spunti di
/// spiritualità, PEG, Drive di Co.Ca.) restano nel codice; il menu del
/// profilo, con «Esci», resta raggiungibile dalla barra in alto.
class AreaAssistenteScreen extends StatelessWidget {
  const AreaAssistenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyBackgroundScreen(
      child: ListView(
        padding: const EdgeInsets.only(
          top: 170,
          left: 20,
          right: 20,
          bottom: 40,
        ),
        children: const [
          JambIntestazione(titolo: 'Assistente Ecclesiastico'),
          SizedBox(height: 24),
          JambLavoriInCorso(
            messaggio:
                'Veglie, spunti di spiritualità e strumenti per l\'Assistente: li stiamo rifacendo.',
          ),
        ],
      ),
    );
  }
}
