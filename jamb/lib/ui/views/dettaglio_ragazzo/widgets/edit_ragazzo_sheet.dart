import 'package:flutter/material.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/contatti_emergenza_widget.dart';

class EditRagazzoSheet extends StatefulWidget {
  final String squadriglia;
  final String ruolo;
  final String allergie;
  final String privacyScadenza;
  final List<ContattoEmergenza> contatti;
  final Function(String squadriglia, String ruolo, String allergie, String privacyScadenza, List<ContattoEmergenza> contatti) onSalva;

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

  void _aggiungiContatto() {
    setState(() {
      _nomiCtrl.add(TextEditingController());
      _telCtrl.add(TextEditingController());
    });
  }

  void _rimuoviContatto(int i) {
    setState(() {
      _nomiCtrl.removeAt(i);
      _telCtrl.removeAt(i);
    });
  }

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
              // Maniglietta
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Modifica Ragazzo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend'),
              ),
              const SizedBox(height: 24),

              // ─── Squadriglia ────────────────────────────────────────────
              _label("Squadriglia"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _squadriglie.map((sq) {
                  final sel = _squadriglia.toLowerCase() == sq.toLowerCase();
                  return GestureDetector(
                    onTap: () => setState(() => _squadriglia = sq),
                    child: _chip(sq.toUpperCase(), sel),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ─── Ruolo ──────────────────────────────────────────────────
              _label("Ruolo"),
              const SizedBox(height: 8),
              Column(
                children: _ruoli.map((r) {
                  final sel = _ruolo == r;
                  return GestureDetector(
                    onTap: () => setState(() => _ruolo = r),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? const Color(0xFF00005C) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r, style: TextStyle(
                            color: sel ? const Color(0xFF00005C) : const Color(0xFF64748B),
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                            fontFamily: 'Lexend',
                          )),
                          if (sel) const Icon(Icons.check_circle, color: Color(0xFF00005C), size: 18),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ─── Allergie ───────────────────────────────────────────────
              _label("Allergie"),
              _textField(_allergieCtrl, hintText: "Es. Arachidi, Polline"),
              const SizedBox(height: 20),

              // ─── Privacy ────────────────────────────────────────────────
              _label("Scadenza Privacy (es. 09/24)"),
              _textField(_privacyCtrl, hintText: "MM/AA", keyboardType: TextInputType.datetime),
              const SizedBox(height: 20),

              // ─── Contatti di Emergenza ──────────────────────────────────
              _label("Contatti di Emergenza"),
              const SizedBox(height: 8),
              ...List.generate(_nomiCtrl.length, (i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Contatto ${i + 1}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
                        GestureDetector(
                          onTap: () => _rimuoviContatto(i),
                          child: const Icon(Icons.close, color: Color(0xFFCBD5E1), size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _inlineField(_nomiCtrl[i], "Nome (es. Padre - Paolo Rossi)"),
                    const SizedBox(height: 6),
                    _inlineField(_telCtrl[i], "Numero di telefono", keyboardType: TextInputType.phone),
                  ],
                ),
              )),
              TextButton.icon(
                onPressed: _aggiungiContatto,
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Aggiungi contatto", style: TextStyle(fontFamily: 'Lexend')),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF00005C)),
              ),
              const SizedBox(height: 24),

              // ─── Pulsanti ───────────────────────────────────────────────
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
                      child: const Text("Annulla", style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontFamily: 'Lexend')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _salva,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00005C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Salva", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700,
      color: Color(0xFF94A3B8), letterSpacing: 0.5, fontFamily: 'Lexend',
    )),
  );

  Widget _chip(String label, bool sel) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: sel ? const Color(0xFF00005C) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: sel ? const Color(0xFF00005C) : const Color(0xFFE2E8F0)),
    ),
    child: Text(label, style: TextStyle(
      color: sel ? Colors.white : const Color(0xFF64748B),
      fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
      fontFamily: 'Lexend',
    )),
  );

  Widget _textField(TextEditingController ctrl, {String? hintText, TextInputType? keyboardType}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend')),
      ),
    );

  Widget _inlineField(TextEditingController ctrl, String hint, {TextInputType? keyboardType}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Lexend', fontSize: 13, color: Color(0xFF1E293B)),
        decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend', fontSize: 13)),
      ),
    );
}
