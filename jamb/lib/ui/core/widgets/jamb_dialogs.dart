import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class JambDialogs {
  static Future<void> showCreateFolderDialog(BuildContext context, {String? initialPath}) {
    return showDialog(
      context: context,
      builder: (context) => _CreateFolderDialog(initialPath: initialPath),
    );
  }

  static Future<void> showUploadDocumentDialog(BuildContext context, {String? initialPath}) {
    return showDialog(
      context: context,
      builder: (context) => _UploadDocumentDialog(initialPath: initialPath),
    );
  }
}

class _CreateFolderDialog extends StatefulWidget {
  final String? initialPath;
  const _CreateFolderDialog({this.initialPath});

  @override
  State<_CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<_CreateFolderDialog> {
  late String _selectedPath;
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPath = widget.initialPath ?? "Drive di Branca";
  }

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      titolo: "Crea Nuova Cartella",
      icona: Icons.create_new_folder_outlined,
      confirmLabel: "CREA",
      onConfirm: () => Navigator.pop(context),
      child: Column(
        children: [
          _buildLabel("Nome Cartella"),
          _buildTextField(controller: _nameCtrl, hint: "es. San Giorgio"),
          const SizedBox(height: 16),
          _buildLabel("Destinazione"),
          _buildDropdown((val) => setState(() => _selectedPath = val!), _selectedPath),
        ],
      ),
    );
  }
}

class _UploadDocumentDialog extends StatefulWidget {
  final String? initialPath;
  const _UploadDocumentDialog({this.initialPath});

  @override
  State<_UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<_UploadDocumentDialog> {
  late String _selectedPath;
  final TextEditingController _nameCtrl = TextEditingController();
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _selectedPath = widget.initialPath ?? "Drive di Branca";
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _nameCtrl.text = _selectedFileName!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      titolo: "Carica Documento",
      icona: Icons.file_upload_outlined,
      confirmLabel: "CARICA",
      onConfirm: () => Navigator.pop(context),
      child: Column(
        children: [
          // Bottone Selezione File
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file_rounded, size: 20, color: Color(0xFF25315B)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFileName ?? "Seleziona file dal dispositivo",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _selectedFileName != null ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                        fontSize: 13,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel("Rinomina File (opzionale)"),
          _buildTextField(controller: _nameCtrl, hint: "Nome finale del documento"),
          const SizedBox(height: 16),
          _buildLabel("Salva in"),
          _buildDropdown((val) => setState(() => _selectedPath = val!), _selectedPath),
        ],
      ),
    );
  }
}

// Elementi comuni rifattorizzati per gestire lo stato
Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          fontFamily: 'Lexend',
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}

Widget _buildTextField({required TextEditingController controller, required String hint}) {
  return TextField(
    controller: controller,
    style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
  );
}

Widget _buildDropdown(ValueChanged<String?> onChanged, String current) {
  // Lista di percorsi finti per l'esempio matrioska
  final List<String> paths = [
    "Drive di Branca",
    "Drive di Branca > 2024-2025",
    "Drive di Branca > 2024-2025 > San Giorgio",
    "Drive di Co.Ca.",
    "Drive di Co.Ca. > Verbali",
    "Modulistica Uscite",
  ];
  
  // Se il path corrente non è in lista (perché dinamico), lo aggiungiamo
  if (!paths.contains(current)) {
    paths.add(current);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: current,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF25315B)),
        items: paths.map((e) => DropdownMenuItem(
          value: e,
          child: Text(
            e, 
            style: const TextStyle(fontSize: 12, fontFamily: 'Lexend', overflow: TextOverflow.ellipsis),
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

class _BaseDialog extends StatelessWidget {
  final String titolo;
  final IconData icona;
  final Widget child;
  final VoidCallback onConfirm;
  final String confirmLabel;

  const _BaseDialog({
    required this.titolo,
    required this.icona,
    required this.child,
    required this.onConfirm,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icona, color: const Color(0xFF25315B), size: 24),
                const SizedBox(width: 12),
                Text(
                  titolo,
                  style: const TextStyle(
                    color: Color(0xFF25315B),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            child,
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "ANNULLA",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25315B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
