import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/evento.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';

/// Testi con cui mostrare una ripetizione nel form e nel dettaglio evento.
extension RipetizioneUi on Ripetizione {
  /// Etichetta della scelta nel form, es. "Ogni settimana".
  String get etichetta => switch (this) {
        Ripetizione.mai => 'Mai',
        Ripetizione.ogniGiorno => 'Ogni giorno',
        Ripetizione.ogniSettimana => 'Ogni settimana',
        Ripetizione.ogniMese => 'Ogni mese',
        Ripetizione.ogniAnno => 'Ogni anno',
      };

  /// Frase per il dettaglio, es. "Si ripete ogni settimana".
  String get descrizione =>
      this == Ripetizione.mai ? 'Non si ripete' : 'Si ripete ${etichetta.toLowerCase()}';
}

/// Chiede se un'azione su un evento ripetuto ([azione], es. "Modifica",
/// "Elimina") vale solo per questo evento o anche per i successivi;
/// `null` se l'utente annulla.
Future<AmbitoSerie?> chiediAmbitoSerie(
  BuildContext context, {
  required String azione,
  bool pericolosa = false,
}) =>
    JambDialogs.scegli(
      context,
      titolo: '$azione evento ripetuto',
      messaggio: 'Questo evento fa parte di una ripetizione.',
      pericolosa: pericolosa,
      opzioni: const [
        ('Solo questo evento', AmbitoSerie.soloQuesto),
        ('Questo e i successivi', AmbitoSerie.questoESuccessivi),
      ],
    );
