import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';

class EditObiettivoDialog extends StatefulWidget {
  final Obiettivo obiettivo;

  const EditObiettivoDialog({
    super.key,
    required this.obiettivo,
  });

  @override
  State<EditObiettivoDialog> createState() => _EditObiettivoDialogState();
}

class _EditObiettivoDialogState extends State<EditObiettivoDialog> {
  late TextEditingController _dominioController;
  late TextEditingController _descrizioneController;
  late TextEditingController _diarioController;
  
  late Color _selectedColor;
  late IconData _selectedIcon;

  // Preset Colors
  final List<Color> _availableColors = [
    const Color(0xFF283664), // Dark Blue
    const Color(0xFF4A6849), // Green
    const Color(0xFFE88A42), // Orange
    const Color(0xFF8B2B33), // Red
    const Color(0xFF4A90E2), // Light Blue
    const Color(0xFF8E44AD), // Purple
  ];

  // Preset Icons
  final List<IconData> _availableIcons = [
    Icons.church,
    Icons.handyman,
    Icons.directions_walk,
    Icons.local_fire_department,
    Icons.park,
    Icons.explore,
    Icons.favorite,
    Icons.flag,
  ];

  @override
  void initState() {
    super.initState();
    _dominioController = TextEditingController(text: widget.obiettivo.dominio);
    _descrizioneController = TextEditingController(text: widget.obiettivo.descrizione);
    _diarioController = TextEditingController(text: widget.obiettivo.diarioDiBordo);
    _selectedColor = widget.obiettivo.colore;
    _selectedIcon = widget.obiettivo.icona;
  }

  @override
  void dispose() {
    _dominioController.dispose();
    _descrizioneController.dispose();
    _diarioController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedObiettivo = widget.obiettivo.copyWith(
      dominio: _dominioController.text,
      descrizione: _descrizioneController.text,
      diarioDiBordo: _diarioController.text,
      colore: _selectedColor,
      icona: _selectedIcon,
    );
    Navigator.of(context).pop(updatedObiettivo);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Modifica Obiettivo",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2660),
              ),
            ),
            const SizedBox(height: 24),
            
            // Dominio
            const Text("Dominio", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dominioController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Descrizione
            const Text("Descrizione", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descrizioneController,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Diario
            const Text("Diario di bordo", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _diarioController,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Colore
            const Text("Colore", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Icona
            const Text("Icona", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: _selectedColor, width: 2) : null,
                    ),
                    child: Icon(icon, color: isSelected ? _selectedColor : Colors.grey.shade600),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Annulla", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2660),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Salva"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
