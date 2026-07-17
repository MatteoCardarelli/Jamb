import 'package:flutter/material.dart';

/// Floating action button standard dell'app.
class JambFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icona;
  final Color? backgroundColor;

  const JambFab({
    super.key,
    required this.onPressed,
    this.icona = Icons.add,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor ?? const Color(0xFF25315B),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              icona,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
