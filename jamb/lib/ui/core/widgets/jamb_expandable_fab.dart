import 'package:flutter/material.dart';

/// Pulsante d'azione flottante espandibile (FAB) con animazione a ventaglio.
/// Quando premuto, rivela opzioni aggiuntive (Crea Cartella, Carica Documento) 
/// con animazioni coordinate di rotazione, scala e opacità.
class JambExpandableFab extends StatefulWidget {
  /// Callback invocata alla pressione di "Crea Cartella"
  final VoidCallback? onCreateFolder;
  /// Callback invocata alla pressione di "Carica Documento"
  final VoidCallback? onUploadDocument;

  const JambExpandableFab({
    super.key,
    this.onCreateFolder,
    this.onUploadDocument,
  });

  @override
  State<JambExpandableFab> createState() => _JambExpandableFabState();
}

class _JambExpandableFabState extends State<JambExpandableFab> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    // Curva di animazione fluida per l'espansione
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Alterna lo stato di apertura/chiusura del menu
  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // OVERLAY SEMITRASPARENTE: Chiude il menu se si tocca fuori
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.black.withOpacity(0.02),
              width: MediaQuery.of(context).size.width * 2,
              height: MediaQuery.of(context).size.height * 2,
            ),
          ),
        
        // BOTTONE PRINCIPALE (Trigger)
        _buildTapToCloseFab(),
        
        // OPZIONE 1: Carica Documento (Distanza 80px)
        _buildStep(
          label: "Carica Documento",
          icon: Icons.file_upload_rounded,
          distance: 80,
          onTap: () {
            _toggle();
            widget.onUploadDocument?.call();
          },
        ),
        
        // OPZIONE 2: Crea Cartella (Distanza 145px)
        _buildStep(
          label: "Crea Cartella",
          icon: Icons.create_new_folder_rounded,
          distance: 145,
          onTap: () {
            _toggle();
            widget.onCreateFolder?.call();
          },
        ),
      ],
    );
  }

  /// Costruisce una singola opzione che "vola" fuori dal FAB principale
  Widget _buildStep({
    required String label,
    required IconData icon,
    required double distance,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Positioned(
          right: 0,
          bottom: distance * _expandAnimation.value, // Posizionamento dinamico basato sull'animazione
          child: FadeTransition(
            opacity: _expandAnimation,
            child: ScaleTransition(
              scale: _expandAnimation,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ETICHETTA (Label)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1D2660),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // ICONA CIRCOLARE
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF1D2660), size: 24),
            ),
          ],
        ),
      ),
    );
  }

  /// Costruisce il FAB principale che ruota di 45 gradi quando aperto
  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 6,
          color: const Color(0xFF1D2660),
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 250),
                turns: _isOpen ? 0.125 : 0, // Ruota di 1/8 di giro (45°) per trasformare '+' in 'x'
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
