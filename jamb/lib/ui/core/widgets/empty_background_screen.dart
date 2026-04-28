import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamb/ui/core/widgets/topbar.dart';
import 'package:jamb/ui/core/widgets/bottom_navbar.dart';

class EmptyBackgroundScreen extends StatefulWidget {
  const EmptyBackgroundScreen({super.key});

  @override
  State<EmptyBackgroundScreen> createState() => _EmptyBackgroundScreenState();
}

class _EmptyBackgroundScreenState extends State<EmptyBackgroundScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // Questo permette alla Navigation Bar di coprire l'inizio dello sfondo
      bottomNavigationBar: const BottomNavBar(),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Sfondo dell'app
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 590,
              child: Image.asset(
                'assets/icons/sfondo.png',
                fit: BoxFit.cover,
              ),
            ),
            // TopBar fissa in alto
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: TopBar(),
            ),
          ],
        ),
      ),
    );
  }
}
