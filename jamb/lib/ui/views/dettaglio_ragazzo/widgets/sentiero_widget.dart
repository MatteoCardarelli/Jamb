import 'package:flutter/material.dart';

class ObiettivoSentiero {
  String titolo;
  bool completato;

  ObiettivoSentiero({required this.titolo, required this.completato});
}

class SentieroWidget extends StatefulWidget {
  final String tappa;
  final String descrizione;
  final List<ObiettivoSentiero> obiettivi;

  const SentieroWidget({
    super.key,
    required this.tappa,
    required this.descrizione,
    required this.obiettivi,
  });

  @override
  State<SentieroWidget> createState() => _SentieroWidgetState();
}

class _SentieroWidgetState extends State<SentieroWidget> {
  late String _tappa;
  late String _descrizione;
  late List<ObiettivoSentiero> _obiettivi;

  @override
  void initState() {
    super.initState();
    _tappa = widget.tappa;
    _descrizione = widget.descrizione;
    // Creiamo una copia mutabile della lista
    _obiettivi = widget.obiettivi.map((o) => ObiettivoSentiero(titolo: o.titolo, completato: o.completato)).toList();
  }

  void _toggleObiettivo(int index) {
    setState(() {
      _obiettivi[index].completato = !_obiettivi[index].completato;
    });
  }

  void _apriModifica() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditSentieroSheet(
        tappa: _tappa,
        descrizione: _descrizione,
        obiettivi: _obiettivi,
        onSalva: (nuovaTappa, nuovaDescrizione, nuoviObiettivi) {
          setState(() {
            _tappa = nuovaTappa;
            _descrizione = nuovaDescrizione;
            _obiettivi = nuoviObiettivi;
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SENTIERO E/G",
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tappa,
                    style: const TextStyle(
                      color: Color(0xFF00005C),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _apriModifica,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _descrizione,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
              fontFamily: 'Lexend',
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Obiettivi:",
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lexend',
            ),
          ),

          const SizedBox(height: 10),

          // Lista obiettivi interattiva
          ...List.generate(_obiettivi.length, (i) {
            final obj = _obiettivi[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _toggleObiettivo(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: obj.completato
                            ? const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22, key: ValueKey('checked'))
                            : Container(
                                key: const ValueKey('unchecked'),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        obj.titolo,
                        style: TextStyle(
                          color: obj.completato ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: obj.completato ? FontWeight.w500 : FontWeight.w400,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Bottom Sheet di Modifica ────────────────────────────────────────────────

class _EditSentieroSheet extends StatefulWidget {
  final String tappa;
  final String descrizione;
  final List<ObiettivoSentiero> obiettivi;
  final Function(String, String, List<ObiettivoSentiero>) onSalva;

  const _EditSentieroSheet({
    required this.tappa,
    required this.descrizione,
    required this.obiettivi,
    required this.onSalva,
  });

  @override
  State<_EditSentieroSheet> createState() => _EditSentieroSheetState();
}

class _EditSentieroSheetState extends State<_EditSentieroSheet> {
  late String _tappaSelezionata;
  late TextEditingController _descCtrl;
  late List<TextEditingController> _obiettiviCtrl;
  late List<bool> _obiettiviCompletati;

  static const List<String> _opzioniTappa = [
    '-',
    'Scoperta',
    'Competenza',
    'Responsabilità',
  ];

  @override
  void initState() {
    super.initState();
    _tappaSelezionata = widget.tappa;
    _descCtrl = TextEditingController(text: widget.descrizione);
    _obiettiviCtrl = widget.obiettivi.map((o) => TextEditingController(text: o.titolo)).toList();
    _obiettiviCompletati = widget.obiettivi.map((o) => o.completato).toList();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    for (final c in _obiettiviCtrl) { c.dispose(); }
    super.dispose();
  }

  void _aggiungiObiettivo() {
    setState(() {
      _obiettiviCtrl.add(TextEditingController());
      _obiettiviCompletati.add(false);
    });
  }

  void _rimuoviObiettivo(int i) {
    setState(() {
      _obiettiviCtrl.removeAt(i);
      _obiettiviCompletati.removeAt(i);
    });
  }

  void _salva() {
    final nuoviObiettivi = List.generate(_obiettiviCtrl.length, (i) =>
      ObiettivoSentiero(titolo: _obiettiviCtrl[i].text, completato: _obiettiviCompletati[i]),
    );
    widget.onSalva(_tappaSelezionata, _descCtrl.text, nuoviObiettivi);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Maniglietta
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Modifica Sentiero", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend')),
              const SizedBox(height: 20),

              _label("Tappa"),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: _opzioniTappa.map((opzione) {
                  final selezionato = _tappaSelezionata == opzione ||
                      (_tappaSelezionata.isEmpty && opzione == '-');
                  return GestureDetector(
                    onTap: () => setState(() => _tappaSelezionata = opzione == '-' ? '' : opzione),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selezionato ? const Color(0xFF00005C) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selezionato ? const Color(0xFF00005C) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        opzione,
                        style: TextStyle(
                          color: selezionato ? Colors.white : const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: selezionato ? FontWeight.w700 : FontWeight.w400,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              _label("Descrizione"),
              _textField(_descCtrl, maxLines: 3),
              const SizedBox(height: 20),

              _label("Obiettivi"),
              const SizedBox(height: 8),

              ...List.generate(_obiettiviCtrl.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _obiettiviCompletati[i] = !_obiettiviCompletati[i]),
                      child: _obiettiviCompletati[i]
                          ? const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 24)
                          : Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFCBD5E1), width: 2)),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _obiettiviCtrl[i],
                        style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Descrivi l'obiettivo...",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _rimuoviObiettivo(i),
                      child: const Icon(Icons.close, color: Color(0xFFCBD5E1), size: 20),
                    ),
                  ],
                ),
              )),

              TextButton.icon(
                onPressed: _aggiungiObiettivo,
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Aggiungi obiettivo", style: TextStyle(fontFamily: 'Lexend')),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF16A34A)),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salva,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00005C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Salva", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.5, fontFamily: 'Lexend')),
  );

  Widget _textField(TextEditingController ctrl, {int maxLines = 1}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)),
      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
    ),
  );
}
