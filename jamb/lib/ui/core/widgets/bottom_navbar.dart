import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamb/ui/views/home/home_view.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, this.currentIndex = 0});

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
            children: [
              _NavBarItem(
                iconPath: currentIndex == 0 ? 'assets/icons/home_2.svg' : 'assets/icons/home_1.svg',
                label: 'Home',
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const HomeView(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                    (route) => false,
                  );
                },
              ),
              _NavBarItem(
                iconPath: 'assets/icons/ragazzi_1.svg',
                label: 'Ragazzi',
                onTap: () {
                  // TODO: rotta per i ragazzi
                },
              ),
              _NavBarItem(
                iconPath: 'assets/icons/documenti_1.svg',
                label: 'Documenti',
                onTap: () {
                  // TODO: rotta per i documenti
                },
              ),
              _NavBarItem(
                iconPath: 'assets/icons/calendario_1.svg',
                label: 'Calendario',
                onTap: () {
                  // TODO: rotta per il calendario
                },
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
      behavior: HitTestBehavior.opaque,
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
              fontWeight: FontWeight.w600, // SemiBold
            ),
          ),
        ],
      ),
    );
  }
}
