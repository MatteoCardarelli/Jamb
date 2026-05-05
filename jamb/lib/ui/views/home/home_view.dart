import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/views/home/widgets/programma_unita_card.dart';
import 'package:jamb/ui/views/home/widgets/alert_medici_widget.dart';
import 'package:jamb/ui/views/home/widgets/azioni_rapide_widget.dart';
import 'package:jamb/ui/views/home/widgets/reparto_card_widget.dart';
import 'package:jamb/ui/views/home/widgets/pillole_metodo_widget.dart';
import 'package:jamb/ui/views/home/widgets/cassa_branca_widget.dart';
import 'package:jamb/ui/views/amministrazione/amministrazione_view.dart';
import 'package:jamb/ui/views/verifica_obiettivi/verifica_obiettivi_view.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/providers/amministrazione_provider.dart';
import 'package:jamb/ui/views/contabilita/contabilita_view.dart';

/// La schermata principale dell'app (Home).
/// Visualizza un riassunto dello stato del reparto, obiettivi e azioni rapide.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Dati di esempio (Mock) per lo sviluppo. 
  // TODO: Spostare in un ObiettiviProvider dedicato nella Fase 3 del refactoring.
  List<Obiettivo> _obiettivi = [
    const Obiettivo(
      id: "1",
      dominio: "Spiritualità",
      descrizione: "Rendere più consapevoli i ragazzi degli eventi cristiani che vivono",
      grado: 5,
      colore: Color(0xFF283664),
      icona: Icons.church,
    ),
    const Obiettivo(
      id: "2",
      dominio: "Abilità manuali",
      descrizione: "Costruzione della cucina da campo ad incastro",
      grado: 4,
      colore: Color(0xFF4A6849),
      icona: Icons.handyman,
    ),
    const Obiettivo(
      id: "3",
      dominio: "Forza fisica",
      descrizione: "Autonomia nello zaino e marcia",
      grado: 3,
      colore: Color(0xFFE88A42),
      icona: Icons.directions_walk,
    ),
  ];

  /// Gestisce la navigazione alla vista di verifica obiettivi e aggiorna lo stato locale
  void _navigateToVerifica(BuildContext context) async {
    final updatedList = await Navigator.of(context).push<List<Obiettivo>>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => VerificaObiettiviView(obiettivi: _obiettivi),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (updatedList != null) {
      setState(() {
        _obiettivi = List.from(updatedList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ascolta il provider per i dati amministrativi
    final adminProvider = Provider.of<AmministrazioneProvider>(context);

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
                    child: ProgrammaUnitaCard(obiettivi: _obiettivi),
                  ),
                  
                  // WIDGET ALLERTA AMMINISTRATIVA (Dati dal Provider)
                  AlertMediciWidget(
                    messaggio: adminProvider.alertMessage,
                    onVediTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const AmministrazioneView(),
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
                          pageBuilder: (context, animation, secondaryAnimation) => const ContabilitaView(),
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
