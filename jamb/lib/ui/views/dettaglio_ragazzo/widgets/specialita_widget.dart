import 'package:flutter/material.dart';

// ─── Modelli ──────────────────────────────────────────────────────────────────

class Prova {
  String descrizione;
  bool completata;
  Prova({required this.descrizione, required this.completata});
}

class Specialita {
  String nome;
  List<Prova> prove;
  DateTime? dataRaggiunta;

  String get imagePath => 'assets/specialita/${nome.toLowerCase().replaceAll(' ', '_')}.jpg';
  bool get raggiunta => prove.every((p) => p.completata) && dataRaggiunta != null;

  Specialita({
    required this.nome,
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
        onElimina: () {
          setState(() => _specialita.removeAt(index));
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(s.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
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
          GestureDetector(
            onTap: _apriAggiungi,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
  final VoidCallback onElimina;
  const _EditSpecialitaSheet({required this.specialita, required this.onSalva, required this.onElimina});

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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(widget.specialita.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(widget.specialita.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend')),
              ],
            ),
            const SizedBox(height: 24),
            const Text("PROVE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
            const SizedBox(height: 12),
            ...List.generate(3, (i) {
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
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final conferma = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text("Elimina specialità", style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w900, color: Color(0xFF00005C))),
                    content: Text("Sei sicuro di voler eliminare la specialità \"${widget.specialita.nome}\"?", style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF64748B))),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Annulla", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF64748B)))),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Elimina", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE11D48), fontWeight: FontWeight.w700))),
                    ],
                  ),
                );
                if (conferma == true) widget.onElimina();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 18),
                    SizedBox(width: 8),
                    Text("Elimina specialità", style: TextStyle(color: Color(0xFFE11D48), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Lexend')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
}

// ─── Sheet Aggiungi Specialità ─────────────────────────────────────────────────

class _AggiungiSpecialitaSheet extends StatefulWidget {
  final Function(Specialita) onAggiungi;
  const _AggiungiSpecialitaSheet({required this.onAggiungi});

  @override
  State<_AggiungiSpecialitaSheet> createState() => _AggiungiSpecialitaSheetState();
}

class _AggiungiSpecialitaSheetState extends State<_AggiungiSpecialitaSheet> {
  String? _nomeSelezionato;
  final List<TextEditingController> _proveCtrl = List.generate(3, (_) => TextEditingController());

  @override
  void dispose() {
    for (var c in _proveCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  static const List<String> _tutteLeSpecialita = [
    'Allevatore', 'Alpinista', 'Amico degli animali', 'Amico del quartiere',
    'Archeologo', 'Artigiano', 'Artista di strada', 'Astronomo', 'Atleta',
    'Attore', 'Battelliere', 'Boscaiolo', 'Botanico', 'Campeggiatore',
    'Canoista', 'Cantante', 'Carpentiere navale', 'Ciclista', 'Collezionista',
    'Coltivatore', 'Corrispondente', 'Corrispondente radio', 'Cuoco',
    'Danzatore', 'Disegnatore', 'Elettricista', 'Elettronico',
    'Esperto del computer', 'Europeista', 'Falegname', 'Fa tutto',
    'Folclorista', 'Fotografo', 'Giardiniere', 'Giocattolaio', 'Grafico',
    'Guida', 'Guida marina', 'Hebertista', 'Idraulico', 'Infermiere',
    'Interprete', 'Lavoratore in cuoio', 'Maestro dei giochi',
    'Maestro dei nodi', 'Meccanico', 'Modellista', 'Muratore', 'Musicista',
    'Naturalista', 'Nuotatore', 'Osservatore', 'Osservatore meteo',
    'Pescatore', 'Pompiere', 'Redattore', 'Regista', 'Sarto', 'Scenografo',
    'Segnalatore', 'Servizio della Parola', 'Servizio liturgico',
    'Servizio missionario', 'Topografo', 'Velista',
  ];

  void _apriSelettore() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchPickerSheet(
        titolo: "Seleziona Specialità",
        voci: _tutteLeSpecialita,
        selezionato: _nomeSelezionato,
        onSeleziona: (v) {
          setState(() => _nomeSelezionato = v);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _conferma() {
    if (_nomeSelezionato == null) return;
    widget.onAggiungi(Specialita(
      nome: _nomeSelezionato!,
      prove: List.generate(3, (i) => Prova(
        descrizione: _proveCtrl[i].text.trim(),
        completata: false,
      )),
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
            const Text("SPECIALITÀ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _apriSelettore,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _nomeSelezionato ?? "Seleziona specialità...",
                        style: TextStyle(fontFamily: 'Lexend', fontSize: 15, color: _nomeSelezionato != null ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_nomeSelezionato != null) ...[
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    image: DecorationImage(
                      image: AssetImage('assets/specialita/${_nomeSelezionato!.toLowerCase().replaceAll(' ', '_')}.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("PROVE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
              const SizedBox(height: 12),
              ...List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00005C)),
                        child: Center(child: Text("${i + 1}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _proveCtrl[i],
                          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontFamily: 'Lexend'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: "Descrizione prova...",
                            hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend', fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
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

// ─── Sheet Ricerca/Selezione Generica ─────────────────────────────────────────

class _SearchPickerSheet extends StatefulWidget {
  final String titolo;
  final List<String> voci;
  final String? selezionato;
  final ValueChanged<String> onSeleziona;

  const _SearchPickerSheet({
    required this.titolo,
    required this.voci,
    required this.selezionato,
    required this.onSeleziona,
  });

  @override
  State<_SearchPickerSheet> createState() => _SearchPickerSheetState();
}

class _SearchPickerSheetState extends State<_SearchPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<String> _filtrate;

  @override
  void initState() {
    super.initState();
    _filtrate = widget.voci;
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() => _filtrate = widget.voci.where((v) => v.toLowerCase().contains(q)).toList());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 8),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(widget.titolo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none, isDense: true,
                prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                hintText: "Cerca...",
                hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _filtrate.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9), height: 1),
              itemBuilder: (_, i) {
                final v = _filtrate[i];
                final sel = v == widget.selezionato;
                final isSpecialita = widget.titolo.contains("Specialità");
                final assetPath = isSpecialita 
                    ? 'assets/specialita/${v.toLowerCase().replaceAll(' ', '_')}.jpg'
                    : 'assets/brevetti/${v.toLowerCase().replaceAll(' ', '_')}.jpg';

                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: AssetImage(assetPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(v, style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                    color: sel ? const Color(0xFF00005C) : const Color(0xFF1E293B),
                  )),
                  trailing: sel ? const Icon(Icons.check, color: Color(0xFF00005C), size: 18) : null,
                  onTap: () => widget.onSeleziona(v),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
