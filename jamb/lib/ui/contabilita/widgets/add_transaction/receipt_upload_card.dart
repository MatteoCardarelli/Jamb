import 'dart:ui';
import 'dart:io' as io; // Usiamo alias per dart:io
import 'package:flutter/foundation.dart'; // Per kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/contabilita/view_model/add_transaction_view_model.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';

/// Componente per l'upload e la visualizzazione dello scontrino/ricevuta.
/// Permette di scegliere tra fotocamera e galleria.
class ReceiptUploadCard extends StatelessWidget {
  const ReceiptUploadCard({super.key});

  void _showPickerOptions(BuildContext context, AddTransactionViewModel viewModel) {
    mostraMenuJamb(
      context,
      titolo: "Carica Scontrino",
      voci: (_) => [
        JambVoceMenu(
          icona: Icons.camera_alt_rounded,
          etichetta: "Scatta una foto",
          onTap: () => viewModel.pickImage(ImageSource.camera),
        ),
        JambVoceMenu(
          icona: Icons.photo_library_rounded,
          etichetta: "Scegli dalla galleria",
          onTap: () => viewModel.pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddTransactionViewModel>();

    return GestureDetector(
      onTap: () => _showPickerOptions(context, viewModel),
      child: CustomPaint(
        painter: DashedBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (viewModel.receiptFile == null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                  child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF1D2660), size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Carica lo scontrino",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend'),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Tocca per scattare una foto o scegliere un file",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontFamily: 'Lexend', fontWeight: FontWeight.w500),
                ),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: kIsWeb 
                    ? Image.network(viewModel.receiptFile!.path, height: 200, width: double.infinity, fit: BoxFit.contain)
                    : Image.file(io.File(viewModel.receiptFile!.path), height: 200, width: double.infinity, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Scontrino pronto: si archivia al salvataggio", 
                      style: TextStyle(color: Color(0xFF1D2660), fontWeight: FontWeight.w800, fontFamily: 'Lexend', fontSize: 13)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tocca per cambiare immagine", 
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'Lexend')
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(24));
    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    const double dashWidth = 10;
    const double dashSpace = 8;
    double distance = 0;

    for (final PathMetric measure in path.computeMetrics()) {
      while (distance < measure.length) {
        dashedPath.addPath(measure.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
      distance = 0;
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
