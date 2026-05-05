import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/allergie_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/contatti_emergenza_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/dettaglio_ragazzo_header.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/edit_ragazzo_sheet.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/privacy_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/sentiero_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/brevetti_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/specialita_widget.dart';

/// Schermata di dettaglio profilo di un singolo ragazzo (scout).
/// Visualizza tutte le informazioni relative all'anagrafica, ai contatti d'emergenza,
/// ai dati medici e al progresso nel sentiero scout (Tappe, Specialità, Brevetti).
class DettaglioRagazzoView extends StatefulWidget {
  /// Nome e cognome dello scout
  final String nome;
  /// Nome della squadriglia di appartenenza
  final String squadriglia;
  /// Ruolo all'interno della squadriglia (es. Capo Squadriglia)
  final String ruolo;
  /// Indica se sono presenti alert medici importanti
  final bool hasAlert;

  const DettaglioRagazzoView({
    super.key,
    required this.nome,
    required this.squadriglia,
    required this.ruolo,
    required this.hasAlert,
  });

  @override
  State<DettaglioRagazzoView> createState() => _DettaglioRagazzoViewState();
}

class _DettaglioRagazzoViewState extends State<DettaglioRagazzoView> {
  // Stato locale per gestire le modifiche temporanee (in attesa di integrazione Provider)
  late String _squadriglia;
  late String _ruolo;
  late bool _hasAlert;
  String _allergie = "Arachidi, Polline";
  String _privacyScadenza = "09/24";
  
  List<ContattoEmergenza> _contatti = [
    ContattoEmergenza(nome: "Padre - Paolo Rossi", telefono: "+39 333 1234567"),
    ContattoEmergenza(nome: "Madre - Maria Verna", telefono: "+39 333 7654321"),
  ];

  @override
  void initState() {
    super.initState();
    _squadriglia = widget.squadriglia;
    _ruolo = widget.ruolo;
    _hasAlert = widget.hasAlert;
  }

  /// Apre il pannello di modifica dei dati anagrafici e contatti
  void _apriModifica() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditRagazzoSheet(
        squadriglia: _squadriglia,
        ruolo: _ruolo,
        allergie: _allergie,
        privacyScadenza: _privacyScadenza,
        contatti: _contatti,
        onSalva: (squadriglia, ruolo, allergie, privacyScadenza, contatti) {
          setState(() {
            _squadriglia = squadriglia;
            _ruolo = ruolo;
            _allergie = allergie;
            _privacyScadenza = privacyScadenza;
            _contatti = contatti;
            _hasAlert = allergie.trim().isNotEmpty;
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 1, // Sezione Ragazzi attiva
        child: Stack(
          children: [
            // --- CORPO DELLA PAGINA (Scrollabile) ---
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // INTESTAZIONE: Foto, Nome e Info Base
                    DettaglioRagazzoHeader(
                      nome: widget.nome,
                      squadriglia: _squadriglia,
                      ruolo: _ruolo,
                      hasAlert: _hasAlert,
                      onEdit: _apriModifica,
                    ),
                    const SizedBox(height: 24),

                    // INFO MEDICHE E PRIVACY
                    if (_allergie.trim().isNotEmpty)
                      Row(
                        children: [
                          Expanded(child: AllergieWidget(allergie: _allergie)),
                          const SizedBox(width: 16),
                          Expanded(child: PrivacyWidget(scadenza: _privacyScadenza)),
                        ],
                      )
                    else
                      PrivacyWidget(scadenza: _privacyScadenza),

                    const SizedBox(height: 24),

                    // CONTATTI DI EMERGENZA
                    ContattiEmergenzaWidget(contatti: _contatti),

                    const SizedBox(height: 24),

                    // PROGRESSO: IL SENTIERO (Tappe)
                    SentieroWidget(
                      tappa: "Tappa della Responsabilità",
                      descrizione: "Acquisire maggiori abilità manuali",
                      obiettivi: [
                        ObiettivoSentiero(titolo: "Specialità di artigiano", completato: true),
                        ObiettivoSentiero(titolo: "Utilizzare il trapano", completato: true),
                        ObiettivoSentiero(titolo: "Imparare 10 nodi", completato: false),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // PROGRESSO: LE SPECIALITÀ
                    SpecialitaWidget(
                      specialita: [
                        Specialita(
                          nome: "Infermiere",
                          prove: [
                            Prova(descrizione: "Conoscere il primo soccorso", completata: false),
                            Prova(descrizione: "Saper fare una fasciatura", completata: false),
                            Prova(descrizione: "Conoscere i numeri di emergenza", completata: false),
                          ],
                        ),
                        Specialita(
                          nome: "Cuoco",
                          prove: [
                            Prova(descrizione: "Pasto completo da campo", completata: true),
                            Prova(descrizione: "Gestione fuoco da campo", completata: true),
                            Prova(descrizione: "Pane su stecco", completata: true),
                          ],
                          dataRaggiunta: DateTime(2026, 4, 26),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // PROGRESSO: I BREVETTI
                    BrevettiWidget(
                      brevetti: [
                        Brevetto(
                          nome: "Naturalista",
                          provaFinaleDescrizione: "Escursione notturna autonoma",
                          specialitaRichieste: [
                            RequisitoBrevetto(nomeSpecialita: "Naturalista", raggiunta: true),
                            RequisitoBrevetto(nomeSpecialita: "Cuoco", raggiunta: true),
                            RequisitoBrevetto(nomeSpecialita: "Topografo", raggiunta: false),
                            RequisitoBrevetto(nomeSpecialita: "Meteorologo", raggiunta: false),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- TASTO BACK (Posizionato in alto a sinistra) ---
            const Positioned(
              top: 60,
              left: 20,
              child: BackActionButton(),
            ),
          ],
        ),
      ),
    );
  }
}
