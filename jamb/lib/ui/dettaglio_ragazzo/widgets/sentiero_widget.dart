import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/progresso.dart'; // Importa entità di dominio

/// Widget per la visualizzazione e gestione del Sentiero scout (E/G).
/// Utilizza le entità di dominio [Tappa] e [Impegno] (Shared Model).
class SentieroWidget extends StatefulWidget {
  final Tappa tappaScout;
  final String descrizione;
  final Function(Tappa)? onChanged;

  const SentieroWidget({
    super.key,
    required this.tappaScout,
    this.descrizione = "Progresso nel sentiero scout",
    this.onChanged,
  });

  @override
  State<SentieroWidget> createState() => _SentieroWidgetState();
}

class _SentieroWidgetState extends State<SentieroWidget> {
  late Tappa _tappa;
  late String _descrizione;

  @override
  void initState() {
    super.initState();
    _tappa = widget.tappaScout;
    _descrizione = widget.descrizione;
  }

  @override
  void didUpdateWidget(SentieroWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tappaScout != widget.tappaScout) {
      _tappa = widget.tappaScout;
    }
    if (oldWidget.descrizione != widget.descrizione) {
      _descrizione = widget.descrizione;
    }
  }

  void _toggleObiettivo(int index) {
    setState(() {
      final nuoviImpegni = List<Impegno>.from(_tappa.impegni);
      nuoviImpegni[index] = nuoviImpegni[index].copyWith(
        isCompletato: !nuoviImpegni[index].isCompletato
      );
      _tappa = _tappa.copyWith(impegni: nuoviImpegni);
      widget.onChanged?.call(_tappa);
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
        onSalva: (nuovaTappa, nuovaDescrizione) {
          setState(() {
            _tappa = nuovaTappa;
            _descrizione = nuovaDescrizione;
            widget.onChanged?.call(_tappa);
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
                        color: Color(0xFF16A34A),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tappa della ${_tappa.tipo.name.toUpperCase()}",
                      style: const TextStyle(
                        color: Color(0xFF1D2660),
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

          ...List.generate(_tappa.impegni.length, (i) {
            final obj = _tappa.impegni[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _toggleObiettivo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: obj.isCompletato ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: obj.isCompletato ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        obj.isCompletato ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: obj.isCompletato ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          obj.titolo,
                          style: TextStyle(
                            color: obj.isCompletato ? const Color(0xFF14532D) : const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: obj.isCompletato ? FontWeight.w700 : FontWeight.w500,
                            fontFamily: 'Lexend',
                            decoration: obj.isCompletato ? TextDecoration.lineThrough : null,
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
  final Tappa tappa;
  final String descrizione;
  final Function(Tappa, String) onSalva;

  const _EditSentieroSheet({
    required this.tappa,
    required this.descrizione,
    required this.onSalva,
  });

  @override
  State<_EditSentieroSheet> createState() => _EditSentieroSheetState();
}

class _EditSentieroSheetState extends State<_EditSentieroSheet> {
  late TappaSentiero _tappaTipo;
  late TextEditingController _descCtrl;
  late List<TextEditingController> _obiettiviCtrl;
  late List<bool> _obiettiviCompletati;

  @override
  void initState() {
    super.initState();
    _tappaTipo = widget.tappa.tipo;
    _descCtrl = TextEditingController(text: widget.descrizione);
    _obiettiviCtrl = widget.tappa.impegni.map((o) => TextEditingController(text: o.titolo)).toList();
    _obiettiviCompletati = widget.tappa.impegni.map((o) => o.isCompletato).toList();
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
    final nuoviImpegni = List.generate(_obiettiviCtrl.length, (i) =>
      Impegno(titolo: _obiettiviCtrl[i].text, isCompletato: _obiettiviCompletati[i]),
    );
    final nuovaTappa = Tappa(tipo: _tappaTipo, impegni: nuoviImpegni);
    widget.onSalva(nuovaTappa, _descCtrl.text);
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
                children: TappaSentiero.values.map((tipo) {
                  final bool isSelected = _tappaTipo == tipo;
                  return GestureDetector(
                    onTap: () => setState(() => _tappaTipo = tipo),
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
                        tipo.name.toUpperCase(),
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
