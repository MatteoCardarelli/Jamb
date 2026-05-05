import 'package:flutter/material.dart';

/// Tipi di file supportati per la visualizzazione personalizzata
enum FileType { pdf, doc, image }

/// Card per la visualizzazione di un documento recente nella lista documenti.
/// Gestisce automaticamente colori e icone in base al formato del file (PDF, Documento, Immagine).
class RecentDocumentCard extends StatelessWidget {
  /// Nome del file
  final String titolo;
  /// Informazioni accessorie (es: "Modificato ieri • 2.4 MB")
  final String info;
  /// Formato del file per la scelta dell'icona e del colore
  final FileType tipo;
  /// Callback invocata al tocco della card
  final VoidCallback? onTap;
  /// Callback invocata alla pressione delle opzioni (tre puntini)
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
          border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICONA FILE: Con sfondo colorato dinamico
            _buildFileIcon(),
            const SizedBox(width: 16),
            
            // TESTI: Titolo e Metadati
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
            
            // AZIONI: Menu opzioni
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

  /// Costruisce l'icona con lo sfondo colorato in base al tipo di file
  Widget _buildFileIcon() {
    Color bgColor;
    Color iconColor;
    IconData iconData;

    switch (tipo) {
      case FileType.pdf:
        bgColor = const Color(0xFFFFE4E1); // Rosso pallido
        iconColor = const Color(0xFFE11D48); // Rosso intenso
        iconData = Icons.picture_as_pdf_rounded;
        break;
      case FileType.doc:
        bgColor = const Color(0xFFE0F2FE); // Blu pallido
        iconColor = const Color(0xFF0284C7); // Blu intenso
        iconData = Icons.description_rounded;
        break;
      case FileType.image:
        bgColor = const Color(0xFFDCFCE7); // Verde pallido
        iconColor = const Color(0xFF16A34A); // Verde intenso
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
