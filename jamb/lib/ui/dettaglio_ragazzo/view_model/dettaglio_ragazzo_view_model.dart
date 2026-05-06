import 'package:flutter/material.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/contatti_emergenza_widget.dart'; // Corretto import per ContattoEmergenza

class DettaglioRagazzoViewModel extends ChangeNotifier {
  String squadriglia;
  String ruolo;
  bool hasAlert;
  String allergie = "Arachidi, Polline";
  String privacyScadenza = "09/24";
  
  List<ContattoEmergenza> contatti = [
    ContattoEmergenza(nome: "Padre - Paolo Rossi", telefono: "+39 333 1234567"),
    ContattoEmergenza(nome: "Madre - Maria Verna", telefono: "+39 333 7654321"),
  ];

  DettaglioRagazzoViewModel({
    required this.squadriglia,
    required this.ruolo,
    required this.hasAlert,
  });

  void aggiornaDati({
    required String nuovaSquadriglia,
    required String nuovoRuolo,
    required String nuoveAllergie,
    required String nuovaPrivacy,
    required List<ContattoEmergenza> nuoviContatti,
  }) {
    squadriglia = nuovaSquadriglia;
    ruolo = nuovoRuolo;
    allergie = nuoveAllergie;
    privacyScadenza = nuovaPrivacy;
    contatti = nuoviContatti;
    hasAlert = allergie.trim().isNotEmpty;
    notifyListeners();
  }
}
