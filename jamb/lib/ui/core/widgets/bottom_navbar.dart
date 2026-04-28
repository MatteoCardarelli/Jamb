import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF25315B),
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _NavBarItem(
                iconPath: 'assets/icons/home_1.svg',
                label: 'Home',
              ),
              _NavBarItem(
                iconPath: 'assets/icons/ragazzi_1.svg',
                label: 'Ragazzi',
              ),
              _NavBarItem(
                iconPath: 'assets/icons/documenti_1.svg',
                label: 'Documenti',
              ),
              _NavBarItem(
                iconPath: 'assets/icons/calendario_1.svg',
                label: 'Calendario',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String iconPath;
  final String label;

  const _NavBarItem({
    required this.iconPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          // Se i file originali sono colorati, commentare la riga sotto; 
          // altrimenti questo li forza a diventare binchi come richiesto dall'immagine.
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
      ],
    );
  }
}
