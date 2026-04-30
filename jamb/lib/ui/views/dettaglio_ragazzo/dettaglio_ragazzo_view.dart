import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/allergie_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/contatti_emergenza_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/dettaglio_ragazzo_header.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/edit_ragazzo_sheet.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/privacy_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/sentiero_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/brevetti_widget.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/specialita_widget.dart';

class DettaglioRagazzoView extends StatefulWidget {
  final String nome;
  final String squadriglia;
  final String ruolo;
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
    return EmptyBackgroundScreen(
      currentIndex: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con callback modifica sui 3 puntini
                  DettaglioRagazzoHeader(
                    nome: widget.nome,
                    squadriglia: _squadriglia,
                    ruolo: _ruolo,
                    hasAlert: _hasAlert,
                    onEdit: _apriModifica,
                  ),
                  const SizedBox(height: 24),

                  // Allergie e Privacy
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

                  // Contatti di Emergenza
                  ContattiEmergenzaWidget(contatti: _contatti),

                  const SizedBox(height: 24),

                  // Sentiero
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

                  // Specialità
                  SpecialitaWidget(
                    specialita: [
                      Specialita(
                        nome: "Infermiere",
                        prove: [
                          Prova(descrizione: "", completata: false),
                          Prova(descrizione: "", completata: false),
                          Prova(descrizione: "", completata: false),
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

                  // Brevetti
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

          // Pulsante Back
          Positioned(
            top: 60,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF25315B)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
