import 'package:flutter/material.dart';

/// Rappresenta un singolo obiettivo all'interno di una tappa del sentiero
class ObiettivoSentiero {
  String titolo;
  bool completato;

  ObiettivoSentiero({required this.titolo, required this.completato});
}

/// Widget per la visualizzazione e gestione del Sentiero scout (E/G).
/// Mostra la tappa corrente, la descrizione dell'impegno e una lista di obiettivi
/// che l'utente può spuntare direttamente. Include un pannello di modifica per la tappa.
class SentieroWidget extends StatefulWidget {
  /// Nome della tappa (es. "Tappa della Responsabilità")
  final String tappa;
  /// Descrizione dell'impegno preso dallo scout
  final String descrizione;
  /// Lista degli obiettivi specifici della tappa
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
    // Copia mutabile della lista per la gestione dello stato locale
    _obiettivi = widget.obiettivi.map((o) => ObiettivoSentiero(titolo: o.titolo, completato: o.completato)).toList();
  }

  /// Inverte lo stato di completamento di un obiettivo
  void _toggleObiettivo(int index) {
    setState(() {
      _obiettivi[index].completato = !_obiettivi[index].completato;
    });
  }

  /// Apre il pannello di modifica per aggiornare la tappa e gli obiettivi
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
          // --- HEADER: TITOLO E TASTO EDIT ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SENTIERO E/G",
                      style: TextStyle(
                        color: Color(0xFF16A34A), // Scout Green
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tappa,
                      style: const TextStyle(
                        color: Color(0xFF1D2660), // Navy Blue
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _apriModifica,
                icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF94A3B8), size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // DESCRIZIONE DELL'IMPEGNO
          Text(
            _descrizione,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontFamily: 'Lexend',
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // LISTA OBIETTIVI INTERATTIVA
          ...List.generate(_obiettivi.length, (i) {
            final obj = _obiettivi[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _toggleObiettivo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: obj.completato ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: obj.completato ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        obj.completato ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: obj.completato ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          obj.titolo,
                          style: TextStyle(
                            color: obj.completato ? const Color(0xFF14532D) : const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: obj.completato ? FontWeight.w700 : FontWeight.w500,
                            fontFamily: 'Lexend',
                            decoration: obj.completato ? TextDecoration.lineThrough : null,
                          ),
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

// --- COMPONENTE PRIVATO: BOTTOM SHEET DI MODIFICA ---

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
    'Nessuna',
    'Scoperta',
    'Competenza',
    'Responsabilità',
  ];

  @override
  void initState() {
    super.initState();
    _tappaSelezionata = widget.tappa.isEmpty ? 'Nessuna' : widget.tappa;
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
    widget.onSalva(_tappaSelezionata == 'Nessuna' ? '' : _tappaSelezionata, _descCtrl.text, nuoviObiettivi);
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
              // MANIGLIA DI CHIUSURA
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Modifica Sentiero", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend')
              ),
              const SizedBox(height: 24),

              _buildLabel("Tappa Corrente"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _opzioniTappa.map((opzione) {
                  final bool isSelected = _tappaSelezionata == opzione;
                  return GestureDetector(
                    onTap: () => setState(() => _tappaSelezionata = opzione),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1D2660) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1D2660) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        opzione,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              _buildLabel("Impegno / Descrizione"),
              _buildTextField(_descCtrl, maxLines: 3, hint: "Descrivi l'impegno preso per questa tappa..."),
              const SizedBox(height: 24),

              _buildLabel("Obiettivi della Tappa"),
              const SizedBox(height: 12),

              ...List.generate(_obiettiviCtrl.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _obiettiviCompletati[i] = !_obiettiviCompletati[i]),
                      child: Icon(
                        _obiettiviCompletati[i] ? Icons.check_circle_rounded : Icons.circle_outlined, 
                        color: _obiettiviCompletati[i] ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _obiettiviCtrl[i],
                        style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "es. Specialità di Cuoco",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _rimuoviObiettivo(i),
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFE11D48), size: 20),
                    ),
                  ],
                ),
              )),

              TextButton.icon(
                onPressed: _aggiungiObiettivo,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text("Aggiungi obiettivo", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF16A34A)),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salva,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2660),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("SALVA MODIFICHE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
                ),
              ),
            ],
          ),
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

  Widget _buildTextField(TextEditingController ctrl, {int maxLines = 1, String? hint}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        border: InputBorder.none, 
        isDense: true
      ),
    ),
  );
}
