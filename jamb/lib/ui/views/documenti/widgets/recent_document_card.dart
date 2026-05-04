import 'package:flutter/material.dart';

enum FileType { pdf, doc, image }

class RecentDocumentCard extends StatelessWidget {
  final String titolo;
  final String info; // es: "Modificato ieri • 2.4 MB"
  final FileType tipo;
  final VoidCallback? onTap;
  final VoidCallback? onOptionsTap;

  const RecentDocumentCard({
    super.key,
    required this.titolo,
    required this.info,
    required this.tipo,
    this.onTap,
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            // Icona file con sfondo colorato
            _buildIcon(),
            const SizedBox(width: 16),
            // Testi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titolo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Menu opzioni (tre puntini)
            IconButton(
              onPressed: onOptionsTap,
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8), size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    Color bgColor;
    Color iconColor;
    IconData iconData;

    switch (tipo) {
      case FileType.pdf:
        bgColor = const Color(0xFFFFE4E1); // Rosa molto chiaro
        iconColor = const Color(0xFFE11D48); // Rosso
        iconData = Icons.picture_as_pdf_rounded;
        break;
      case FileType.doc:
        bgColor = const Color(0xFFE0F2FE); // Celeste chiaro
        iconColor = const Color(0xFF0284C7); // Blu
        iconData = Icons.description_rounded;
        break;
      case FileType.image:
        bgColor = const Color(0xFFDCFCE7); // Verde chiaro
        iconColor = const Color(0xFF16A34A); // Verde
        iconData = Icons.image_rounded;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }
}
