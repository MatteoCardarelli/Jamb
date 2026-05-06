import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/allergie_widget.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/contatti_emergenza_widget.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/dettaglio_ragazzo_header.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/edit_ragazzo_sheet.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/privacy_widget.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/sentiero_widget.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/brevetti_widget.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/specialita_widget.dart';
import 'package:jamb/ui/dettaglio_ragazzo/view_model/dettaglio_ragazzo_view_model.dart';

/// Schermata di dettaglio profilo di un singolo ragazzo (scout).
/// Visualizza tutte le informazioni relative all'anagrafica, ai contatti d'emergenza,
/// ai dati medici e al progresso nel sentiero scout (Tappe, Specialità, Brevetti).
class DettaglioRagazzoScreen extends StatelessWidget {
  /// Nome e cognome dello scout
  final String nome;

  const DettaglioRagazzoScreen({
    super.key,
    required this.nome,
  });

  /// Apre il pannello di modifica dei dati anagrafici e contatti
  void _apriModifica(BuildContext context) {
    final viewModel = context.read<DettaglioRagazzoViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditRagazzoSheet(
        squadriglia: viewModel.squadriglia,
        ruolo: viewModel.ruolo,
        allergie: viewModel.allergie,
        privacyScadenza: viewModel.privacyScadenza,
        contatti: viewModel.contatti,
        onSalva: (squadriglia, ruolo, allergie, privacyScadenza, contatti) {
          viewModel.aggiornaDati(
            nuovaSquadriglia: squadriglia,
            nuovoRuolo: ruolo,
            nuoveAllergie: allergie,
            nuovaPrivacy: privacyScadenza,
            nuoviContatti: contatti,
          );
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DettaglioRagazzoViewModel>();

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
                      nome: nome,
                      squadriglia: viewModel.squadriglia,
                      ruolo: viewModel.ruolo,
                      hasAlert: viewModel.hasAlert,
                      onEdit: () => _apriModifica(context),
                    ),
                    const SizedBox(height: 24),

                    // INFO MEDICHE E PRIVACY
                    if (viewModel.allergie.trim().isNotEmpty)
                      Row(
                        children: [
                          Expanded(child: AllergieWidget(allergie: viewModel.allergie)),
                          const SizedBox(width: 16),
                          Expanded(child: PrivacyWidget(scadenza: viewModel.privacyScadenza)),
                        ],
                      )
                    else
                      PrivacyWidget(scadenza: viewModel.privacyScadenza),

                    const SizedBox(height: 24),

                    // CONTATTI DI EMERGENZA
                    ContattiEmergenzaWidget(contatti: viewModel.contatti),

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
