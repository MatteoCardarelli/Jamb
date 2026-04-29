import 'package:flutter/material.dart';

class RagazziSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onClear;

  const RagazziSearchBar({super.key, required this.controller, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Cerca scout o squadriglia...",
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontFamily: 'Lexend'),
                border: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      controller.clear();
                      onClear?.call();
                    },
                    child: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 18),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
