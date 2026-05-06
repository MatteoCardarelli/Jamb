import 'package:flutter/material.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/contatti_emergenza_widget.dart';
import 'package:intl/intl.dart';

/// Pannello (BottomSheet) per la modifica dei dati anagrafici e dei contatti di uno scout.
/// Gestisce lo stato locale tramite TextEditingController per consentire l'annullamento
/// delle modifiche prima del salvataggio definitivo tramite callback.
class EditRagazzoSheet extends StatefulWidget {
  final String squadriglia;
  final String ruolo;
  final String allergie;
  final String privacyScadenza;
  final List<ContattoEmergenza> contatti;
  
  /// Callback invocata al salvataggio con i nuovi dati validati
  final Function(
    String squadriglia, 
    String ruolo, 
    String allergie, 
    String privacyScadenza, 
    List<ContattoEmergenza> contatti
  ) onSalva;

  const EditRagazzoSheet({
    super.key,
    required this.squadriglia,
    required this.ruolo,
    required this.allergie,
    required this.privacyScadenza,
    required this.contatti,
    required this.onSalva,
  });

  @override
  State<EditRagazzoSheet> createState() => _EditRagazzoSheetState();
}

class _EditRagazzoSheetState extends State<EditRagazzoSheet> {
  // --- STATO LOCALE E CONTROLLER ---
  late String _squadriglia;
  late String _ruolo;
  late TextEditingController _allergieCtrl;
  late TextEditingController _privacyCtrl;
  late List<TextEditingController> _nomiCtrl;
  late List<TextEditingController> _telCtrl;

  static const List<String> _squadriglie = ['Volpi', 'Aquile', 'Lupi', 'Pantere', 'Tigri', 'Leoni'];
  static const List<String> _ruoli = ['Capo Squadriglia', 'Vice Capo', 'Squadrigliere'];

  @override
  void initState() {
    super.initState();
    _squadriglia = widget.squadriglia;
    _ruolo = widget.ruolo;
    _allergieCtrl = TextEditingController(text: widget.allergie);
    _privacyCtrl = TextEditingController(text: widget.privacyScadenza);
    
    // Inizializzazione dinamica dei controller per i contatti
    _nomiCtrl = widget.contatti.map((c) => TextEditingController(text: c.nome)).toList();
    _telCtrl = widget.contatti.map((c) => TextEditingController(text: c.telefono)).toList();
  }

  @override
  void dispose() {
    _allergieCtrl.dispose();
    _privacyCtrl.dispose();
    for (final c in _nomiCtrl) { c.dispose(); }
    for (final c in _telCtrl) { c.dispose(); }
    super.dispose();
  }

  /// Aggiunge una nuova coppia di campi per un contatto di emergenza
  void _aggiungiContatto() {
    setState(() {
      _nomiCtrl.add(TextEditingController());
      _telCtrl.add(TextEditingController());
    });
  }

  /// Rimuove un contatto specifico dalla lista
  void _rimuoviContatto(int i) {
    setState(() {
      _nomiCtrl.removeAt(i);
      _telCtrl.removeAt(i);
    });
  }

  /// Mostra il calendario per selezionare la scadenza privacy
  Future<void> _selezionaDataPrivacy() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1D2660))),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _privacyCtrl.text = DateFormat('MM/yy').format(picked);
      });
    }
  }

  /// Raccoglie i dati dai controller e invoca la callback di salvataggio
  void _salva() {
    final contatti = List.generate(_nomiCtrl.length, (i) =>
      ContattoEmergenza(nome: _nomiCtrl[i].text, telefono: _telCtrl[i].text),
    );
    widget.onSalva(_squadriglia, _ruolo, _allergieCtrl.text, _privacyCtrl.text, contatti);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MANIGLIA DI CHIUSURA
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Modifica Ragazzo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend'),
            ),
            const SizedBox(height: 24),

            // SELEZIONE SQUADRIGLIA
            _buildLabel("Squadriglia"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _squadriglie.map((sq) {
                final isSelected = _squadriglia.toLowerCase() == sq.toLowerCase();
                return GestureDetector(
                  onTap: () => setState(() => _squadriglia = sq),
                  child: _buildChip(sq.toUpperCase(), isSelected),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // SELEZIONE RUOLO (Lista verticale)
            _buildLabel("Ruolo in Squadriglia"),
            const SizedBox(height: 8),
            ..._ruoli.map((r) {
              final isSelected = _ruolo == r;
              return GestureDetector(
                onTap: () => setState(() => _ruolo = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? const Color(0xFF1D2660) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r, style: TextStyle(
                        color: isSelected ? const Color(0xFF1D2660) : const Color(0xFF64748B),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        fontFamily: 'Lexend',
                      )),
                      if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF1D2660), size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // CAMPI DI TESTO (Allergie e Privacy)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Allergie"),
                      _buildTextField(_allergieCtrl, hintText: "Es. Arachidi..."),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Privacy"),
                      GestureDetector(
                        onTap: _selezionaDataPrivacy,
                        child: AbsorbPointer(
                          child: _buildTextField(_privacyCtrl, hintText: "MM/YY"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // GESTIONE CONTATTI DI EMERGENZA
            _buildLabel("Contatti di Emergenza"),
            const SizedBox(height: 12),
            ...List.generate(_nomiCtrl.length, (i) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("CONTATTO ${i + 1}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
                      IconButton(
                        onPressed: () => _rimuoviContatto(i),
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFE11D48), size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInlineField(_nomiCtrl[i], "Nome (es. Madre)"),
                  const SizedBox(height: 8),
                  _buildInlineField(_telCtrl[i], "Numero di telefono", keyboardType: TextInputType.phone),
                ],
              ),
            )),
            
            TextButton.icon(
              onPressed: _aggiungiContatto,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text("Aggiungi contatto", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1D2660)),
            ),
            
            const SizedBox(height: 32),

            // TASTI SALVA / ANNULLA
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("ANNULLA", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _salva,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D2660),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("SALVA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(), 
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')
    ),
  );

  Widget _buildChip(String label, bool isSelected) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFF1D2660) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isSelected ? const Color(0xFF1D2660) : const Color(0xFFE2E8F0)),
    ),
    child: Text(label, style: TextStyle(
      color: isSelected ? Colors.white : const Color(0xFF64748B),
      fontSize: 13, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
      fontFamily: 'Lexend',
    )),
  );

  Widget _buildTextField(TextEditingController ctrl, {String? hintText, TextInputType? keyboardType}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          border: InputBorder.none, 
          isDense: true, 
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend')
        ),
      ),
    );

  Widget _buildInlineField(TextEditingController ctrl, String hint, {TextInputType? keyboardType}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          border: InputBorder.none, 
          isDense: true, 
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend', fontSize: 13)
        ),
      ),
    );
}
