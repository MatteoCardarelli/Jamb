import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/ui/documenti/widgets/tipo_documento_ui.dart';

/// Card per la visualizzazione di un documento recente nella lista documenti.
/// Icona e colori dipendono dal tipo di file (PDF, documento, immagine, ...).
class RecentDocumentCard extends StatelessWidget {
  /// Nome del file
  final String titolo;
  /// Informazioni accessorie (es: "Modificato ieri • 2,4 MB")
  final String info;
  /// Formato del file per la scelta dell'icona e del colore
  final TipoDocumento tipo;
  /// Callback invocata al tocco della card
  final VoidCallback? onTap;
  /// Callback del pulsante opzioni (tre puntini); senza, il pulsante non compare
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
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICONA FILE: Con sfondo colorato dinamico
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tipo.sfondo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(tipo.icona, color: tipo.colore, size: 22),
            ),
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
            if (onOptionsTap != null)
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
}
