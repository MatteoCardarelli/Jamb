import 'package:flutter/material.dart';

class BackActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackActionButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F1F5), // Light grey background
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: Color(0xFF1D2660), // Dark blue arrow
          size: 28,
        ),
      ),
    );
  }
}
