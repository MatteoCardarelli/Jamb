import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/topbar.dart';
import 'package:jamb/ui/core/widgets/bottom_navbar.dart';

/// Layout base universale per le schermate dell'applicazione Jamb.
/// Fornisce lo sfondo istituzionale, la TopBar, la BottomNavBar e la gestione
/// intelligente dello spazio quando la tastiera è visibile.
class EmptyBackgroundScreen extends StatefulWidget {
  /// Il contenuto principale della schermata
  final Widget? child;
  /// Widget flottante opzionale (es. JambExpandableFab)
  final Widget? floatingActionButton;
  /// Indice della sezione corrente per evidenziare l'elemento nella BottomNavBar
  final int currentIndex;
  /// Se impostato a true, lo scaffold si ridimensiona per lasciare spazio alla tastiera
  final bool resizeToAvoidBottomInset;

  const EmptyBackgroundScreen({
    super.key, 
    this.child,
    this.floatingActionButton,
    this.currentIndex = 0,
    this.resizeToAvoidBottomInset = false,
  });

  @override
  State<EmptyBackgroundScreen> createState() => _EmptyBackgroundScreenState();
}

class _EmptyBackgroundScreenState extends State<EmptyBackgroundScreen> {
  @override
  Widget build(BuildContext context) {
    // Determiniamo se la tastiera è aperta per nascondere componenti ingombranti
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // Permette al corpo di estendersi sotto la BottomNavBar
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      
      // Nasconde la Navbar se la tastiera è aperta per lasciare più spazio all'input
      bottomNavigationBar: isKeyboardOpen ? null : BottomNavBar(currentIndex: widget.currentIndex),
      
      floatingActionButton: widget.floatingActionButton,
      
      body: SizedBox.expand(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // --- 1. STRATO SFONDO (Immagine istituzionale) ---
            // Il posizionamento è calcolato dall'alto per evitare l'effetto "fisarmonica"
            // quando la tastiera si apre e lo schermo si ridimensiona.
            Positioned(
              top: MediaQuery.of(context).size.height - 590, 
              left: 0,
              right: 0,
              height: 590,
              child: Image.asset(
                'assets/icons/sfondo.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // --- 2. STRATO CONTENUTO (Child) ---
            if (widget.child != null)
              Positioned.fill(
                child: widget.child!,
              ),

            // --- 3. STRATO TOPBAR (Sempre in primo piano) ---
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
