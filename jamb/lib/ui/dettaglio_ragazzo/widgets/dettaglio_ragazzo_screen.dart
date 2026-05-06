import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/scout.dart';
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
/// Utilizza l'entità di dominio [Scout] (Shared Model).
class DettaglioRagazzoScreen extends StatelessWidget {
  final Scout scout;

  const DettaglioRagazzoScreen({
    super.key,
    required this.scout,
  });

  void _apriModifica(BuildContext context) {
    final viewModel = context.read<DettaglioRagazzoViewModel>();
    final s = viewModel.scout;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditRagazzoSheet(
        squadriglia: s.squadriglia,
        ruolo: s.ruolo,
        allergie: s.allergie ?? "",
        privacyScadenza: s.scadenzaPrivacy != null ? "${s.scadenzaPrivacy!.month}/${s.scadenzaPrivacy!.year}" : "",
        contatti: s.contattiEmergenza,
        onSalva: (squadriglia, ruolo, allergie, privacyScadenza, contatti) {
          // In una implementazione reale qui mapperemmo i dati e chiameremmo il ViewModel
          viewModel.aggiornaDati(s.copyWith(
            squadriglia: squadriglia,
            ruolo: ruolo,
            allergie: allergie,
            contattiEmergenza: contatti,
          ));
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DettaglioRagazzoViewModel>();
    final s = viewModel.scout;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 1,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DettaglioRagazzoHeader(
                      nome: s.nome,
                      squadriglia: s.squadriglia,
                      ruolo: s.ruolo,
                      hasAlert: viewModel.hasAlert,
                      onEdit: () => _apriModifica(context),
                    ),
                    const SizedBox(height: 24),

                    if (s.allergie != null && s.allergie!.trim().isNotEmpty)
                      Row(
                        children: [
                          Expanded(child: AllergieWidget(allergie: s.allergie!)),
                          const SizedBox(width: 16),
                          Expanded(child: PrivacyWidget(
                            scadenza: s.scadenzaPrivacy != null 
                              ? "${s.scadenzaPrivacy!.month.toString().padLeft(2, '0')}/${s.scadenzaPrivacy!.year.toString().substring(2)}" 
                              : "N/D"
                          )),
                        ],
                      )
                    else
                      PrivacyWidget(
                        scadenza: s.scadenzaPrivacy != null 
                          ? "${s.scadenzaPrivacy!.month.toString().padLeft(2, '0')}/${s.scadenzaPrivacy!.year.toString().substring(2)}" 
                          : "N/D"
                      ),

                    const SizedBox(height: 24),

                    ContattiEmergenzaWidget(contatti: s.contattiEmergenza),

                    const SizedBox(height: 24),

                    SentieroWidget(
                      tappaScout: s.progresso.tappaAttuale,
                      onChanged: (nuovaTappa) {
                        viewModel.aggiornaDati(s.copyWith(
                          progresso: s.progresso.copyWith(tappaAttuale: nuovaTappa),
                        ));
                      },
                    ),

                    const SizedBox(height: 24),

                    SpecialitaWidget(
                      specialita: s.progresso.specialita,
                    ),

                    const SizedBox(height: 24),

                    BrevettiWidget(
                      brevetti: s.progresso.brevetti,
                    ),
                  ],
                ),
              ),
            ),

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
