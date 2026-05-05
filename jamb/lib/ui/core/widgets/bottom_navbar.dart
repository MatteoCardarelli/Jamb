import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamb/ui/views/home/home_view.dart';
import 'package:jamb/ui/views/ragazzi/ragazzi_view.dart';
import 'package:jamb/ui/views/documenti/documenti_view.dart';

/// Barra di navigazione inferiore globale dell'applicazione.
/// Gestisce il passaggio tra le sezioni principali (Home, Ragazzi, Documenti, Calendario)
/// utilizzando transizioni istantanee per un'esperienza utente reattiva.
class BottomNavBar extends StatelessWidget {
  /// Indice della sezione attualmente attiva (0: Home, 1: Ragazzi, 2: Documenti, 3: Calendario)
  final int currentIndex;

  const BottomNavBar({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF25315B), // Blu scuro Jamb
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: SafeArea(
        top: false, // Evita padding extra se non necessario
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ITEM: HOME
              _NavBarItem(
                iconPath: currentIndex == 0 ? 'assets/icons/home_2.svg' : 'assets/icons/home_1.svg',
                label: 'Home',
                onTap: () => _navigateTo(context, const HomeView()),
              ),
              
              // ITEM: RAGAZZI
              _NavBarItem(
                iconPath: currentIndex == 1 ? 'assets/icons/ragazzi_2.svg' : 'assets/icons/ragazzi_1.svg',
                label: 'Ragazzi',
                onTap: () => _navigateTo(context, const RagazziView()),
              ),
              
              // ITEM: DOCUMENTI
              _NavBarItem(
                iconPath: currentIndex == 2 ? 'assets/icons/documenti_2.svg' : 'assets/icons/documenti_1.svg',
                label: 'Documenti',
                onTap: () => _navigateTo(context, const DocumentiView()),
              ),
              
              // ITEM: CALENDARIO
              _NavBarItem(
                iconPath: 'assets/icons/calendario_1.svg',
                label: 'Calendario',
                onTap: () {
                  // TODO: Implementare modulo Calendario
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper per la navigazione globale con rimozione dello stack e transazione istantanea.
  void _navigateTo(BuildContext context, Widget view) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => view,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false, // Pulisce completamente lo stack per evitare loop di navigazione
    );
  }
}

/// Widget interno per la rappresentazione di un singolo elemento della barra di navigazione.
class _NavBarItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Assicura che l'area cliccabile sia l'intero spazio disponibile
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
