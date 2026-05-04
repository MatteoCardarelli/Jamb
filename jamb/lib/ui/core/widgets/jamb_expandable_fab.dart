import 'package:flutter/material.dart';

class JambExpandableFab extends StatefulWidget {
  final VoidCallback? onCreateFolder;
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
        // Overlay scuro quando aperto
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.black.withOpacity(0.05),
              width: MediaQuery.of(context).size.width * 2,
              height: MediaQuery.of(context).size.height * 2,
            ),
          ),
        
        // Opzioni che compaiono
        _buildTapToCloseFab(),
        _buildStep(
          label: "Carica Documento",
          icon: Icons.file_upload_outlined,
          distance: 80,
          onTap: () {
            _toggle();
            widget.onUploadDocument?.call();
          },
        ),
        _buildStep(
          label: "Crea Cartella",
          icon: Icons.create_new_folder_outlined,
          distance: 145,
          onTap: () {
            _toggle();
            widget.onCreateFolder?.call();
          },
        ),
      ],
    );
  }

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
          bottom: distance * _expandAnimation.value,
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
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF25315B),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Icona
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF25315B), size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          color: const Color(0xFF25315B),
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 250),
                turns: _isOpen ? 0.125 : 0, // Ruota di 45 gradi per far diventare + una x
                child: Icon(
                  _isOpen ? Icons.add : Icons.add, // Uso sempre add ma ruoto
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
