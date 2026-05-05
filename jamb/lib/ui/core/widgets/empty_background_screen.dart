import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamb/ui/core/widgets/topbar.dart';
import 'package:jamb/ui/core/widgets/bottom_navbar.dart';

class EmptyBackgroundScreen extends StatefulWidget {
  final Widget? child;
  final Widget? floatingActionButton;
  final int currentIndex;
  final bool resizeToAvoidBottomInset; // AGGIUNTO PARAMETRO

  const EmptyBackgroundScreen({
    super.key, 
    this.child,
    this.floatingActionButton,
    this.currentIndex = 0,
    this.resizeToAvoidBottomInset = false, // Default a false per compatibilità
  });

  @override
  State<EmptyBackgroundScreen> createState() => _EmptyBackgroundScreenState();
}

class _EmptyBackgroundScreenState extends State<EmptyBackgroundScreen> {
  @override
  Widget build(BuildContext context) {
    // Calcoliamo lo spazio occupato dalla tastiera
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, 
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset, // USA IL PARAMETRO
      bottomNavigationBar: isKeyboardOpen ? null : BottomNavBar(currentIndex: widget.currentIndex), // Nasconde navbar se tastiera aperta
      floatingActionButton: widget.floatingActionButton,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Sfondo dell'app - FISSO (Non usa Positioned bottom: 0 per evitare fisarmonica)
            Positioned(
              top: MediaQuery.of(context).size.height - 590, // Fissato dall'alto rispetto alla altezza totale
              left: 0,
              right: 0,
              height: 590,
              child: Image.asset(
                'assets/icons/sfondo.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // Corpo Principale
            if (widget.child != null)
              Positioned.fill(
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
