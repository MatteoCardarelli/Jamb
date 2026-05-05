import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';

/// Dialogo modale per la modifica completa di un obiettivo.
/// Gestisce l'editing di testi (Dominio, Descrizione, Diario), la scelta del colore e dell'icona.
class EditObiettivoDialog extends StatefulWidget {
  /// L'obiettivo originale da pre-caricare nel form
  final Obiettivo obiettivo;
  /// Lista dei colori già utilizzati da altri obiettivi
  final List<Color> usedColors;

  const EditObiettivoDialog({
    super.key,
    required this.obiettivo,
    this.usedColors = const [],
  });

  @override
  State<EditObiettivoDialog> createState() => _EditObiettivoDialogState();
}

class _EditObiettivoDialogState extends State<EditObiettivoDialog> {
  // Controller per i campi di testo
  late TextEditingController _dominioController;
  late TextEditingController _descrizioneController;
  late TextEditingController _diarioController;
  
  // Stato locale per le selezioni grafiche
  late Color _selectedColor;
  late IconData _selectedIcon;

  // Palette di colori predefiniti per gli obiettivi
  final List<Color> _availableColors = [
    const Color(0xFF283664), // Blu Notte
    const Color(0xFF4A6849), // Verde Bosco
    const Color(0xFFE88A42), // Arancione Fuoco
    const Color(0xFF8B2B33), // Rosso Carminio
    const Color(0xFF4A90E2), // Azzurro Cielo
    const Color(0xFF8E44AD), // Viola Scout
  ];

  // Set di icone tematiche disponibili
  final List<IconData> _availableIcons = [
    Icons.church_rounded,
    Icons.handyman_rounded,
    Icons.directions_walk_rounded,
    Icons.local_fire_department_rounded,
    Icons.park_rounded,
    Icons.explore_rounded,
    Icons.favorite_rounded,
    Icons.flag_rounded,
  ];

  @override
  void initState() {
    super.initState();
    // Inizializzazione dei campi con i dati correnti dell'obiettivo
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

  /// Crea una nuova entità Obiettivo con i dati aggiornati e chiude il dialogo
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITOLO DEL DIALOGO
            const Text(
              "Modifica Obiettivo",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D2660),
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 24),
            
            // CAMPI DI TESTO
            _buildInputField("Dominio", _dominioController),
            const SizedBox(height: 16),
            _buildInputField("Descrizione", _descrizioneController, maxLines: 2),
            const SizedBox(height: 16),
            _buildInputField("Diario di bordo", _diarioController, maxLines: 3),
            
            const SizedBox(height: 24),

            // SELEZIONE COLORE
            const Text(
              "Colore Tematico",
              style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Lexend', fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                // Un colore è considerato "usato" se è nella lista usedColors
                final isUsed = widget.usedColors.contains(color);
                
                return GestureDetector(
                  onTap: isUsed ? null : () => setState(() => _selectedColor = color),
                  child: Opacity(
                    opacity: isUsed ? 0.3 : 1.0,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: const Color(0xFF1D2660), width: 3) : null,
                        boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)] : null,
                      ),
                      child: isUsed ? const Icon(Icons.close_rounded, color: Colors.white, size: 20) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),

            // SELEZIONE ICONA
            const Text(
              "Icona Identificativa",
              style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Lexend', fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor.withOpacity(0.15) : const Color(0xFFF4F6F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon, 
                      color: isSelected ? _selectedColor : const Color(0xFF64748B),
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // TASTI DI AZIONE
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Annulla", 
                    style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontFamily: 'Lexend'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2660),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Salva Modifiche",
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Lexend'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Helper per costruire un campo di input coerente con lo stile dell'app
  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Lexend',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontFamily: 'Lexend', fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1D2660), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
