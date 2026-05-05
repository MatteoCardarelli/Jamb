import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptUploadCard extends StatefulWidget {
  const ReceiptUploadCard({super.key});

  @override
  State<ReceiptUploadCard> createState() => _ReceiptUploadCardState();
}

class _ReceiptUploadCardState extends State<ReceiptUploadCard> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selected = await _picker.pickImage(source: source);
    if (selected != null) {
      setState(() {
        _image = File(selected.path);
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Carica Scontrino",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF000066), fontFamily: 'Lexend'),
              ),
              const SizedBox(height: 24),
              _buildOption(
                icon: Icons.camera_alt_rounded,
                label: "Scatta una foto",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: Icons.photo_library_rounded,
                label: "Scegli dalla galleria",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF000066)),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontFamily: 'Lexend')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPickerOptions,
      child: CustomPaint(
        painter: DashedBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              if (_image == null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF000066), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Carica lo scontrino",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontFamily: 'Lexend'),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Trascina qui o scatta una foto",
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontFamily: 'Lexend'),
                ),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                const Text("Scontrino caricato", style: TextStyle(color: Color(0xFF000066), fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
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
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(24));
    
    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    const double dashWidth = 8;
    const double dashSpace = 6;
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
