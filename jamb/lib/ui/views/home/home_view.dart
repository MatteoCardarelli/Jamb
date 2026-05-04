import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/views/home/widgets/programma_unita_card.dart';
import 'package:jamb/ui/views/home/widgets/alert_medici_widget.dart';
import 'package:jamb/ui/views/home/widgets/azioni_rapide_widget.dart';
import 'package:jamb/ui/views/home/widgets/reparto_card_widget.dart';
import 'package:jamb/ui/views/home/widgets/pillole_metodo_widget.dart';
import 'package:jamb/ui/views/home/widgets/cassa_branca_widget.dart';
import 'package:jamb/ui/views/documenti/amministrazione_view.dart';
import 'package:jamb/ui/views/verifica_obiettivi/verifica_obiettivi_view.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/providers/amministrazione_provider.dart';
import 'package:jamb/ui/views/documenti/widgets/status_row_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Mock data for MVP
  List<Obiettivo> _obiettivi = [
    const Obiettivo(
      id: "1",
      dominio: "Spiritualità",
      descrizione: "Rendere più consapevoli i ragazzi degli eventi cristiani che vivono",
      grado: 5,
      colore: Color(0xFF283664), // Dark Blue
      icona: Icons.church,
    ),
    const Obiettivo(
      id: "2",
      dominio: "Abilità manuali",
      descrizione: "Costruzione della cucina da campo ad incastro",
      grado: 4,
      colore: Color(0xFF4A6849), // Green
      icona: Icons.handyman,
    ),
    const Obiettivo(
      id: "3",
      dominio: "Forza fisica",
      descrizione: "Autonomia nello zaino e marcia",
      grado: 3,
      colore: Color(0xFFE88A42), // Orange
      icona: Icons.directions_walk,
    ),
  ];

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
    final adminProvider = Provider.of<AmministrazioneProvider>(context);

    // Calcolo allerta dinamica dai dati centralizzati
    int medScadute = adminProvider.ragazzi.where((e) => e.medica == DocumentStatus.missing).length;
    int medInScadenza = adminProvider.ragazzi.where((e) => e.medica == DocumentStatus.expiring).length;
    int censMancanti = adminProvider.ragazzi.where((e) => e.censimento == DocumentStatus.none || e.censimento == DocumentStatus.missing).length;

    List<String> alerts = [];
    if (medScadute > 0) alerts.add("$medScadute schede mediche scadute");
    if (medInScadenza > 0) alerts.add("$medInScadenza in scadenza");
    if (censMancanti > 0) alerts.add("$censMancanti censimenti mancanti");

    String alertMessage = alerts.isNotEmpty ? "${alerts.join(", ")}." : "";

    return EmptyBackgroundScreen(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToVerifica(context),
                    child: ProgrammaUnitaCard(obiettivi: _obiettivi),
                  ),
                  
                  // Iniezione del Widget di Allerta DINAMICO
                  AlertMediciWidget(
                    messaggio: alertMessage,
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
                  
                  // Iniezione della griglia Azioni Rapide
                  const AzioniRapideWidget(),
                  
                  // Iniezione Card Reparto
                  const RepartoCardWidget(),
                  
                  // Iniezione widget Pillole del Metodo
                  const PilloleMetodoWidget(),
                  
                  // Iniezione widget Cassa di Branca
                  const CassaBrancaWidget(),
                  
                  // Altri widget andranno qui
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
