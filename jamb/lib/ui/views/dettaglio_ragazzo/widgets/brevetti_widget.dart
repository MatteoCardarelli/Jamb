import 'package:flutter/material.dart';

// ─── Modelli ──────────────────────────────────────────────────────────────────

class RequisitoBrevetto {
  String nomeSpecialita;
  bool raggiunta;
  RequisitoBrevetto({required this.nomeSpecialita, required this.raggiunta});
}

class Brevetto {
  String nome;
  List<RequisitoBrevetto> specialitaRichieste; // esattamente 4
  String provaFinaleDescrizione;
  bool provaFinaleSuperata;
  DateTime? dataOttenimento;

  String get imagePath => 'assets/brevetti/${nome.toLowerCase().replaceAll(' ', '_')}.jpg';
  bool get prerequisitiRaggunti => specialitaRichieste.every((s) => s.raggiunta);
  bool get ottenuto => prerequisitiRaggunti && provaFinaleSuperata && dataOttenimento != null;

  Brevetto({
    required this.nome,
    required this.specialitaRichieste,
    required this.provaFinaleDescrizione,
    this.provaFinaleSuperata = false,
    this.dataOttenimento,
  });
}

// ─── Widget Lista Brevetti ─────────────────────────────────────────────────────

class BrevettiWidget extends StatefulWidget {
  final List<Brevetto> brevetti;
  const BrevettiWidget({super.key, required this.brevetti});

  @override
  State<BrevettiWidget> createState() => _BrevettiWidgetState();
}

class _BrevettiWidgetState extends State<BrevettiWidget> {
  late List<Brevetto> _brevetti;

  @override
  void initState() {
    super.initState();
    _brevetti = widget.brevetti;
  }

  String _sottotitolo(Brevetto b) {
    if (b.ottenuto) {
      final d = b.dataOttenimento!;
      return "ottenuto il ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    }
    final raggiunte = b.specialitaRichieste.where((s) => s.raggiunta).length;
    if (raggiunte < 4) return "$raggiunte/4 specialità completate";
    return "Specialità ok · prova finale mancante";
  }

  void _apriDettaglio(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditBrevettoSheet(
        brevetto: _brevetti[index],
        onSalva: (aggiornato) {
          setState(() => _brevetti[index] = aggiornato);
          Navigator.of(ctx).pop();
        },
        onElimina: () {
          setState(() => _brevetti.removeAt(index));
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
      builder: (ctx) => _AggiungiBrevettoSheet(
        onAggiungi: (nuovo) {
          setState(() => _brevetti.add(nuovo));
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
          const Text("Brevetti", style: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
          const SizedBox(height: 16),
          if (_brevetti.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text("Nessun brevetto aggiunto.", style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Lexend')),
            )
          else
            ...List.generate(_brevetti.length, (i) {
              final b = _brevetti[i];
              final raggiunte = b.specialitaRichieste.where((s) => s.raggiunta).length;
              return Column(
                children: [
                  if (i > 0) const Divider(color: Color(0xFFF1F5F9), height: 24),
                  GestureDetector(
                    onTap: () => _apriDettaglio(i),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(b.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.nome, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                              const SizedBox(height: 2),
                              Text(_sottotitolo(b), style: TextStyle(
                                color: b.ottenuto ? const Color(0xFF16A34A) : (raggiunte == 4 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8)),
                                fontSize: 13, fontFamily: 'Lexend',
                              )),
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
                  Text("Aggiungi brevetto", style: TextStyle(color: Color(0xFF00005C), fontWeight: FontWeight.w600, fontFamily: 'Lexend')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet Modifica Brevetto ───────────────────────────────────────────────────

class _EditBrevettoSheet extends StatefulWidget {
  final Brevetto brevetto;
  final Function(Brevetto) onSalva;
  final VoidCallback onElimina;
  const _EditBrevettoSheet({required this.brevetto, required this.onSalva, required this.onElimina});

  @override
  State<_EditBrevettoSheet> createState() => _EditBrevettoSheetState();
}

class _EditBrevettoSheetState extends State<_EditBrevettoSheet> {
  late List<bool> _raggiunte;
  late bool _provaFinale;
  DateTime? _data;

  @override
  void initState() {
    super.initState();
    _raggiunte = widget.brevetto.specialitaRichieste.map((s) => s.raggiunta).toList();
    _provaFinale = widget.brevetto.provaFinaleSuperata;
    _data = widget.brevetto.dataOttenimento;
  }

  bool get _tuttiPrerequisiti => _raggiunte.every((r) => r);
  bool get _ottenuto => _tuttiPrerequisiti && _provaFinale;

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
    final aggiornato = Brevetto(
      nome: widget.brevetto.nome,
      provaFinaleDescrizione: widget.brevetto.provaFinaleDescrizione,
      provaFinaleSuperata: _provaFinale,
      dataOttenimento: _ottenuto ? _data : null,
      specialitaRichieste: List.generate(4, (i) => RequisitoBrevetto(
        nomeSpecialita: widget.brevetto.specialitaRichieste[i].nomeSpecialita,
        raggiunta: _raggiunte[i],
      )),
    );
    widget.onSalva(aggiornato);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(widget.brevetto.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.brevetto.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend'))),
              ],
            ),
            const SizedBox(height: 24),

            // Specialità prerequisito
            const Text("SPECIALITÀ RICHIESTE (4)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
            const SizedBox(height: 12),
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _raggiunte[i] = !_raggiunte[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _raggiunte[i] ? const Color(0xFFEAFAEF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _raggiunte[i] ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _raggiunte[i]
                            ? const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22, key: ValueKey('on'))
                            : Container(key: const ValueKey('off'), width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFCBD5E1), width: 2))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(
                        widget.brevetto.specialitaRichieste[i].nomeSpecialita,
                        style: TextStyle(color: _raggiunte[i] ? const Color(0xFF166534) : const Color(0xFF64748B), fontSize: 14, fontFamily: 'Lexend'),
                      )),
                    ],
                  ),
                ),
              ),
            )),

            const SizedBox(height: 8),
            // Prova finale (sbloccata solo se tutti i prerequisiti ok)
            const Text("PROVA FINALE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')),
            const SizedBox(height: 8),
            Opacity(
              opacity: _tuttiPrerequisiti ? 1.0 : 0.4,
              child: GestureDetector(
                onTap: _tuttiPrerequisiti ? () => setState(() => _provaFinale = !_provaFinale) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _provaFinale ? const Color(0xFFEAFAEF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _provaFinale ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _provaFinale
                            ? const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22, key: ValueKey('on'))
                            : Container(key: const ValueKey('off'), width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFCBD5E1), width: 2))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(
                        widget.brevetto.provaFinaleDescrizione.isNotEmpty ? widget.brevetto.provaFinaleDescrizione : "Prova finale",
                        style: TextStyle(color: _provaFinale ? const Color(0xFF166534) : const Color(0xFF64748B), fontSize: 14, fontFamily: 'Lexend'),
                      )),
                    ],
                  ),
                ),
              ),
            ),

            // Data ottenimento
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _ottenuto ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text("DATA DI OTTENIMENTO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A), letterSpacing: 0.8, fontFamily: 'Lexend')),
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
            // Elimina
            GestureDetector(
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text("Elimina brevetto", style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w900, color: Color(0xFF00005C))),
                    content: Text("Vuoi eliminare il brevetto \"${widget.brevetto.nome}\"?", style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF64748B))),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Annulla", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF64748B)))),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Elimina", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE11D48), fontWeight: FontWeight.w700))),
                    ],
                  ),
                );
                if (ok == true) widget.onElimina();
              },
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECDD3))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 18),
                  SizedBox(width: 8),
                  Text("Elimina brevetto", style: TextStyle(color: Color(0xFFE11D48), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Lexend')),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Annulla", style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontFamily: 'Lexend')),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: _salva,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00005C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Salva", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet Aggiungi Brevetto ───────────────────────────────────────────────────

class _AggiungiBrevettoSheet extends StatefulWidget {
  final Function(Brevetto) onAggiungi;
  const _AggiungiBrevettoSheet({required this.onAggiungi});
  @override
  State<_AggiungiBrevettoSheet> createState() => _AggiungiBrevettoSheetState();
}

class _AggiungiBrevettoSheetState extends State<_AggiungiBrevettoSheet> {
  String? _nome;
  final _provaCtrl = TextEditingController();
  final List<TextEditingController> _sc = List.generate(4, (_) => TextEditingController());

  static const List<String> _brevetti = ['Naturalista', 'Artista', 'Giornalista', 'Grafico multimediale', 'Cittadino del mondo', 'Liturgista', 'Animatore sportivo', 'Guida alpina', 'Mani Abili', 'Pioniere', 'Soccorritore', 'Sherpa', 'Trappeur', 'Maestro delle Tecnologie', 'Esploratore delle acque'];
  static const Map<String, List<String>> _req = {
    'Naturalista': ['Naturalista', 'Botanico', 'Osservatore meteo', 'Astronomo'],
    'Artista': ['Artista di strada', 'Danzatore', 'Musicista', 'Attore'],
    'Giornalista': ['Corrispondente', 'Fotografo', 'Redattore', 'Regista'],
    'Grafico multimediale': ['Grafico', 'Fotografo', 'Esperto del computer', 'Scenografo'],
    'Cittadino del mondo': ['Europeista', 'Interprete', 'Guida', 'Folclorista'],
    'Liturgista': ['Servizio liturgico', 'Servizio della Parola', 'Servizio missionario', 'Musicista'],
    'Animatore sportivo': ['Atleta', 'Hebertista', 'Nuotatore', 'Maestro dei giochi'],
    'Guida alpina': ['Alpinista', 'Topografo', 'Campeggiatore', 'Hebertista'],
    'Mani Abili': ['Falegname', 'Muratore', 'Elettricista', 'Artigiano'],
    'Pioniere': ['Campeggiatore', 'Boscaiolo', 'Maestro dei nodi', 'Topografo'],
    'Soccorritore': ['Infermiere', 'Pompiere', 'Nuotatore', 'Atleta'],
    'Sherpa': ['Alpinista', 'Boscaiolo', 'Campeggiatore', 'Naturalista'],
    'Trappeur': ['Botanico', 'Pescatore', 'Naturalista', 'Campeggiatore'],
    'Maestro delle Tecnologie': ['Esperto del computer', 'Elettronico', 'Elettricista', 'Modellista'],
    'Esploratore delle acque': ['Nuotatore', 'Canoista', 'Velista', 'Guida marina'],
  };

  @override
  void dispose() {
    _provaCtrl.dispose();
    for (final c in _sc) { c.dispose(); }
    super.dispose();
  }

  void _apri() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BrevettoPickerSheet(
        voci: _brevetti,
        selezionato: _nome,
        onSeleziona: (v) {
          setState(() {
            _nome = v;
            final r = _req[v] ?? ['', '', '', ''];
            for (int i = 0; i < 4; i++) _sc[i].text = i < r.length ? r[i] : '';
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _ok() {
    if (_nome == null) return;
    widget.onAggiungi(Brevetto(
      nome: _nome!,
      provaFinaleDescrizione: _provaCtrl.text.trim(),
      specialitaRichieste: List.generate(4, (i) => RequisitoBrevetto(
        nomeSpecialita: _sc[i].text.trim().isNotEmpty ? _sc[i].text.trim() : 'Specialità ${i + 1}',
        raggiunta: false,
      )),
    ));
  }

  Widget _lbl(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')));
  Widget _fld(TextEditingController c, String h) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))), child: TextField(controller: c, style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)), decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: h, hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend'))));

  @override
  Widget build(BuildContext context) {
    final bp = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bp + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text("Nuovo Brevetto", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend')),
            const SizedBox(height: 20),
            _lbl("BREVETTO"),
            GestureDetector(
              onTap: _apri,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(children: [Expanded(child: Text(_nome ?? "Seleziona brevetto...", style: TextStyle(fontFamily: 'Lexend', fontSize: 15, color: _nome != null ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)))), const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8))]),
              ),
            ),
            const SizedBox(height: 16),
            _lbl("PROVA FINALE"), _fld(_provaCtrl, "Descrivi la prova finale..."),
            const SizedBox(height: 16),
            _lbl("4 SPECIALITÀ RICHIESTE"),
            if (_nome != null) Padding(padding: const EdgeInsets.only(bottom: 8, top: 4), child: Text("Auto-compilate per $_nome", style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontFamily: 'Lexend'))),
            const SizedBox(height: 4),
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00005C)), child: Center(child: Text("${i + 1}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 10),
                Expanded(child: _fld(_sc[i], "Nome specialità ${i + 1}")),
              ]),
            )),
            const SizedBox(height: 16),
            if (_nome != null)
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    image: DecorationImage(
                      image: AssetImage('assets/brevetti/${_nome!.toLowerCase().replaceAll(' ', '_')}.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Annulla", style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontFamily: 'Lexend')))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: _ok, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00005C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Aggiungi", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Lexend')))),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Picker Brevetto ──────────────────────────────────────────────────────────

class _BrevettoPickerSheet extends StatefulWidget {
  final List<String> voci;
  final String? selezionato;
  final ValueChanged<String> onSeleziona;
  const _BrevettoPickerSheet({required this.voci, required this.selezionato, required this.onSeleziona});
  @override
  State<_BrevettoPickerSheet> createState() => _BrevettoPickerSheetState();
}

class _BrevettoPickerSheetState extends State<_BrevettoPickerSheet> {
  final _c = TextEditingController();
  late List<String> _f;
  @override
  void initState() {
    super.initState();
    _f = widget.voci;
    _c.addListener(() {
      final q = _c.text.toLowerCase();
      setState(() => _f = widget.voci.where((v) => v.toLowerCase().contains(q)).toList());
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = MediaQuery.of(context).padding.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bp + 8),
      child: Column(children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text("Seleziona Brevetto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF00005C), fontFamily: 'Lexend')),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: TextField(controller: _c, style: const TextStyle(fontFamily: 'Lexend', fontSize: 14), decoration: const InputDecoration(border: InputBorder.none, isDense: true, prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20), hintText: "Cerca...", hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'Lexend'))),
        ),
        const SizedBox(height: 8),
        Expanded(child: ListView.separated(
          itemCount: _f.length,
          separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9), height: 1),
          itemBuilder: (_, i) {
            final v = _f[i];
            final s = v == widget.selezionato;
            return ListTile(
              dense: true,
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: AssetImage('assets/brevetti/${v.toLowerCase().replaceAll(' ', '_')}.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(v, style: TextStyle(fontFamily: 'Lexend', fontWeight: s ? FontWeight.w700 : FontWeight.w400, color: s ? const Color(0xFF00005C) : const Color(0xFF1E293B))),
              trailing: s ? const Icon(Icons.check, color: Color(0xFF00005C), size: 18) : null,
              onTap: () => widget.onSeleziona(v),
            );
          },
        )),
      ]),
    );
  }
}
