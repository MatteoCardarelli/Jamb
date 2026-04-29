import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamb/ui/core/widgets/topbar.dart';
import 'package:jamb/ui/core/widgets/bottom_navbar.dart';

class EmptyBackgroundScreen extends StatefulWidget {
  final Widget? child;
  final int currentIndex;

  const EmptyBackgroundScreen({
    super.key, 
    this.child,
    this.currentIndex = 0,
  });

  @override
  State<EmptyBackgroundScreen> createState() => _EmptyBackgroundScreenState();
}

class _EmptyBackgroundScreenState extends State<EmptyBackgroundScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, 
      resizeToAvoidBottomInset: false, // Impedisce alla tastiera di alzare lo sfondo
      bottomNavigationBar: BottomNavBar(currentIndex: widget.currentIndex),
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
            
            // Corpo Principale Iniettato (Home, ecc.)
            if (widget.child != null)
              Positioned.fill(
                // Ripristinato a 0: la pagina coprirà l'intero schermo e spetterà 
                // ai singoli elementi interni (es. un ListView) darsi il padding iniziale.
                // Così scorrendo andranno dolcemente "sotto" la TopBar!
                top: 0, 
                child: widget.child!,
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
