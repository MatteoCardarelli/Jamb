import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/views/home/widgets/programma_unita_card.dart';
import 'package:jamb/ui/views/verifica_obiettivi/verifica_obiettivi_view.dart';

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
