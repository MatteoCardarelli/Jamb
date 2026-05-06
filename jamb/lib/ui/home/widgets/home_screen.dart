import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/home/widgets/programma_unita_card.dart';
import 'package:jamb/ui/home/widgets/alert_medici_widget.dart';
import 'package:jamb/ui/home/widgets/azioni_rapide_widget.dart';
import 'package:jamb/ui/home/widgets/reparto_card_widget.dart';
import 'package:jamb/ui/home/widgets/pillole_metodo_widget.dart';
import 'package:jamb/ui/home/widgets/cassa_branca_widget.dart';
import 'package:jamb/ui/amministrazione/widgets/amministrazione_screen.dart';
import 'package:jamb/ui/verifica_obiettivi/widgets/verifica_obiettivi_screen.dart';
import 'package:jamb/ui/verifica_obiettivi/view_model/verifica_obiettivi_view_model.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/amministrazione/view_model/amministrazione_view_model.dart';
import 'package:jamb/ui/contabilita/widgets/contabilita_screen.dart';
import 'package:jamb/ui/home/view_model/home_view_model.dart';

/// La schermata principale dell'app (Home).
/// Visualizza un riassunto dello stato del reparto, obiettivi e azioni rapide.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Gestisce la navigazione alla vista di verifica obiettivi e aggiorna lo stato locale
  void _navigateToVerifica(BuildContext context) async {
    final viewModel = context.read<HomeViewModel>();
    final updatedList = await Navigator.of(context).push<List<Obiettivo>>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChangeNotifierProvider(
          create: (_) => VerificaObiettiviViewModel(viewModel.obiettivi),
          child: const VerificaObiettiviScreen(),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (updatedList != null) {
      viewModel.updateObiettivi(updatedList);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ascolta i provider per i dati necessari
    final adminProvider = Provider.of<AmministrazioneViewModel>(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);

    return EmptyBackgroundScreen(
      child: Stack(
        children: [
          // AREA SCORREVOLE PRINCIPALE
          Positioned.fill(
            child: SingleChildScrollView(
              // Padding di 170 per lasciare spazio alla TopBar flottante
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD PROGRAMMA D'UNITÀ (Obiettivi)
                  GestureDetector(
                    onTap: () => _navigateToVerifica(context),
                    child: ProgrammaUnitaCard(obiettivi: homeViewModel.obiettivi),
                  ),
                  
                  // WIDGET ALLERTA AMMINISTRATIVA (Dati dal Provider)
                  AlertMediciWidget(
                    messaggio: homeViewModel.alertMessage,
                    onVediTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const AmministrazioneScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  
                  // SEZIONE AZIONI RAPIDE (Griglia pulsanti)
                  const AzioniRapideWidget(),
                  
                  // CARD REPARTO (Info generali)
                  const RepartoCardWidget(),
                  
                  // PILLOLE DEL METODO (Contenuto educativo)
                  const PilloleMetodoWidget(),
                  
                  // CASSA DI BRANCA (Contabilità veloce)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const ContabilitaScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: const CassaBrancaWidget(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
