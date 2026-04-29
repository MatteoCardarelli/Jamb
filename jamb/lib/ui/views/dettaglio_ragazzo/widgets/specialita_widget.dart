import 'package:flutter/material.dart';

// ─── Modelli ──────────────────────────────────────────────────────────────────

class Prova {
  String descrizione;
  bool completata;
  Prova({required this.descrizione, required this.completata});
}

class Specialita {
  String nome;
  IconData icona;
  Color coloreIcona;
  List<Prova> prove;
  DateTime? dataRaggiunta;

  bool get raggiunta => prove.every((p) => p.completata) && dataRaggiunta != null;

  Specialita({
    required this.nome,
    required this.icona,
    required this.coloreIcona,
    required this.prove,
    this.dataRaggiunta,
  });
}

// ─── Widget Lista ──────────────────────────────────────────────────────────────

class SpecialitaWidget extends StatefulWidget {
  final List<Specialita> specialita;
  const SpecialitaWidget({super.key, required this.specialita});

  @override
  State<SpecialitaWidget> createState() => _SpecialitaWidgetState();
}

class _SpecialitaWidgetState extends State<SpecialitaWidget> {
  late List<Specialita> _specialita;

  @override
  void initState() {
    super.initState();
    _specialita = widget.specialita;
  }

  String _sottotitolo(Specialita s) {
    if (s.raggiunta) {
      final d = s.dataRaggiunta!;
      return "raggiunta il ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    }
    // Prima prova non completata
    final idx = s.prove.indexWhere((p) => !p.completata);
    if (idx == -1) return "Tutte le prove completate";
    final desc = s.prove[idx].descrizione.trim();
    return "${idx + 1}ª prova: ${desc.isNotEmpty ? desc : 'da definire'}";
  }

  void _apriDettaglio(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditSpecialitaSheet(
        specialita: _specialita[index],
        onSalva: (aggiornata) {
          setState(() => _specialita[index] = aggiornata);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _apriAggiungi() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AggiungiSpecialitaSheet(
        onAggiungi: (nuova) {
          setState(() => _specialita.add(nuova));
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Specialità Attive", style: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
          const SizedBox(height: 16),
          ...List.generate(_specialita.length, (i) {
            final s = _specialita[i];
            return Column(
              children: [
                if (i > 0) const Divider(color: Color(0xFFF1F5F9), height: 24),
                GestureDetector(
                  onTap: () => _apriDettaglio(i),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: s.coloreIcona.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Icon(s.icona, color: s.coloreIcona, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.nome, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                            const SizedBox(height: 2),
                            Text(_sottotitolo(s), style: TextStyle(color: s.raggiunta ? const Color(0xFF16A34A) : const Color(0xFF94A3B8), fontSize: 13, fontFamily: 'Lexend')),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          // Pulsante aggiungi
          GestureDetector(
            onTap: _apriAggiungi,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Color(0xFF00005C), size: 18),
                  SizedBox(width: 8),
                  Text("Aggiungi specialità", style: TextStyle(color: Color(0xFF00005C), fontWeight: FontWeight.w600, fontFamily: 'Lexend')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet Modifica Specialità ─────────────────────────────────────────────────

class _EditSpecialitaSheet extends StatefulWidget {
  final Specialita specialita;
  final Function(Specialita) onSalva;
  const _EditSpecialitaSheet({required this.specialita, required this.onSalva});

  @override
  State<_EditSpecialitaSheet> createState() => _EditSpecialitaSheetState();
}

class _EditSpecialitaSheetState extends State<_EditSpecialitaSheet> {
  late List<bool> _prove;
  late List<TextEditingController> _proveCtrl;
  DateTime? _data;

  bool get _tutteCompletate => _prove.every((p) => p);

  @override
  void initState() {
    super.initState();
    _prove = widget.specialita.prove.map((p) => p.completata).toList();
    _proveCtrl = widget.specialita.prove.map((p) => TextEditingController(text: p.descrizione)).toList();
    _data = widget.specialita.dataRaggiunta;
  }

  @override
  void dispose() {
    for (final c in _proveCtrl) { c.dispose(); }
    super.dispose();
  }

  Future<void> _selezionaData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _data = picked);
  }

  void _salva() {
    final aggiornata = Specialita(
      nome: widget.specialita.nome,
      icona: widget.specialita.icona,
      coloreIcona: widget.specialita.coloreIcona,
      prove: List.generate(3, (i) => Prova(descrizione: _proveCtrl[i].text.trim(), completata: _prove[i])),
      dataRaggiunta: _tutteCompletate ? _data : null,
    );
    widget.onSalva(aggiornata);
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: widget.specialita.coloreIcona.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(widget.specialita.icona, color: widget.specialita.coloreIcona, size: 24),
                ),
                const SizedBox(width: 12),
                Text(widget.specialita.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend')),
              ],
            ),
            const SizedBox(height: 24),
            const Text("PROVE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
            const SizedBox(height: 12),
            ...List.generate(3, (i) {
              // Bloccato se la prova precedente non è completata
              final sbloccata = i == 0 || _prove[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Opacity(
                  opacity: sbloccata ? 1.0 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _prove[i] ? const Color(0xFFEAFAEF) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _prove[i] ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: sbloccata ? () => setState(() => _prove[i] = !_prove[i]) : null,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _prove[i]
                                ? const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22, key: ValueKey('on'))
                                : Container(
                                    key: const ValueKey('off'),
                                    width: 22, height: 22,
                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFCBD5E1), width: 2)),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("${i + 1}ª ", style: TextStyle(color: _prove[i] ? const Color(0xFF166534) : const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                        Expanded(
                          child: TextField(
                            controller: _proveCtrl[i],
                            enabled: sbloccata,
                            style: TextStyle(color: _prove[i] ? const Color(0xFF166534) : const Color(0xFF64748B), fontSize: 14, fontFamily: 'Lexend'),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: "Descrivi la prova...", hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend', fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _tutteCompletate ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text("DATA DI RAGGIUNGIMENTO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A), letterSpacing: 0.8, fontFamily: 'Lexend')),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selezionaData,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: const Color(0xFFEAFAEF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF86EFAC))),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Color(0xFF16A34A), size: 18),
                          const SizedBox(width: 12),
                          Text(
                            _data != null ? "${_data!.day.toString().padLeft(2, '0')}/${_data!.month.toString().padLeft(2, '0')}/${_data!.year}" : "Seleziona la data...",
                            style: TextStyle(color: _data != null ? const Color(0xFF166534) : const Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Lexend'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ) : const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Pulsante Annulla
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
                // Pulsante Salva
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
}

// ─── Sheet Aggiungi Specialità ─────────────────────────────────────────────────

class _AggiungiSpecialitaSheet extends StatefulWidget {
  final Function(Specialita) onAggiungi;
  const _AggiungiSpecialitaSheet({required this.onAggiungi});

  @override
  State<_AggiungiSpecialitaSheet> createState() => _AggiungiSpecialitaSheetState();
}

class _AggiungiSpecialitaSheetState extends State<_AggiungiSpecialitaSheet> {
  final _nomeCtrl = TextEditingController();
  int _iconaIndex = 0;
  int _coloreIndex = 0;

  static const List<IconData> _icone = [
    Icons.medical_services_outlined,
    Icons.restaurant_outlined,
    Icons.build_outlined,
    Icons.forest_outlined,
    Icons.music_note_outlined,
    Icons.directions_run_outlined,
    Icons.photo_camera_outlined,
    Icons.computer_outlined,
    Icons.sports_soccer_outlined,
    Icons.science_outlined,
  ];

  static const List<Color> _colori = [
    Color(0xFFF59E0B),
    Color(0xFF16A34A),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFFDB2777),
    Color(0xFF65A30D),
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  void _conferma() {
    if (_nomeCtrl.text.trim().isEmpty) return;
    widget.onAggiungi(Specialita(
      nome: _nomeCtrl.text.trim(),
      icona: _icone[_iconaIndex],
      coloreIcona: _colori[_coloreIndex],
      prove: [
        Prova(descrizione: "", completata: false),
        Prova(descrizione: "", completata: false),
        Prova(descrizione: "", completata: false),
      ],
    ));
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text("Nuova Specialità", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend')),
            const SizedBox(height: 20),
            const Text("NOME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: TextField(
                controller: _nomeCtrl,
                style: const TextStyle(fontFamily: 'Lexend', fontSize: 15, color: Color(0xFF1E293B)),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: "Es. Infermiere", hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend')),
              ),
            ),
            const SizedBox(height: 20),
            const Text("ICONA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: List.generate(_icone.length, (i) => GestureDetector(
                onTap: () => setState(() => _iconaIndex = i),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _iconaIndex == i ? _colori[_coloreIndex].withOpacity(0.15) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _iconaIndex == i ? _colori[_coloreIndex] : const Color(0xFFE2E8F0), width: _iconaIndex == i ? 2 : 1),
                  ),
                  child: Icon(_icone[i], color: _iconaIndex == i ? _colori[_coloreIndex] : const Color(0xFF94A3B8), size: 24),
                ),
              )),
            ),
            const SizedBox(height: 20),
            const Text("COLORE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: List.generate(_colori.length, (i) => GestureDetector(
                onTap: () => setState(() => _coloreIndex = i),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _colori[i],
                    shape: BoxShape.circle,
                    border: Border.all(color: _coloreIndex == i ? const Color(0xFF00005C) : Colors.transparent, width: 3),
                    boxShadow: _coloreIndex == i ? [BoxShadow(color: _colori[i].withOpacity(0.4), blurRadius: 8)] : null,
                  ),
                ),
              )),
            ),
            const SizedBox(height: 24),
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
                    onPressed: _conferma,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00005C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Aggiungi", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
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
