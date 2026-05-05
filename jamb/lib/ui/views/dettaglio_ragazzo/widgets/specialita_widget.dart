import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_search_picker.dart';

// --- MODELLI DI DATI ---

/// Rappresenta una singola prova (delle 3 necessarie) per ottenere una specialità.
class Prova {
  String descrizione;
  bool completata;
  Prova({required this.descrizione, required this.completata});
}

/// Rappresenta una specialità scout con le sue 3 prove e l'eventuale data di raggiungimento.
class Specialita {
  final String nome;
  final List<Prova> prove;
  final DateTime? dataRaggiunta;

  /// Percorso dell'immagine della specialità basato sul nome
  String get imagePath => 'assets/specialita/${nome.toLowerCase().replaceAll(' ', '_')}.jpg';
  
  /// Indica se la specialità è stata interamente completata e assegnata
  bool get raggiunta => prove.every((p) => p.completata) && dataRaggiunta != null;

  Specialita({
    required this.nome,
    required this.prove,
    this.dataRaggiunta,
  });
}

// --- WIDGET PRINCIPALE ---

/// Widget per la visualizzazione e gestione delle Specialità attive di uno scout.
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
          const Text(
            "Specialità Attive", 
            style: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Lexend')
          ),
          const SizedBox(height: 16),
          ...List.generate(_specialita.length, (i) {
            final s = _specialita[i];
            return Column(
              children: [
                if (i > 0) const Divider(color: Color(0xFFF1F5F9), height: 24, thickness: 1.5),
                GestureDetector(
                  onTap: () => _apriDettaglio(i),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(image: AssetImage(s.imagePath), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.nome, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                            const SizedBox(height: 2),
                            Text(_sottotitolo(s), style: TextStyle(color: s.raggiunta ? const Color(0xFF16A34A) : const Color(0xFF94A3B8), fontSize: 13, fontWeight: s.raggiunta ? FontWeight.w600 : FontWeight.w400, fontFamily: 'Lexend')),
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
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _apriAggiungi,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1D2660), size: 18),
                  SizedBox(width: 8),
                  Text("Aggiungi specialità", style: TextStyle(color: Color(0xFF1D2660), fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SHEET MODIFICA SPECIALITÀ ---

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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1D2660))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data = picked);
  }

  void _salva() {
    final aggiornata = Specialita(
      nome: widget.specialita.nome,
      prove: List.generate(3, (i) => Prova(descrizione: _proveCtrl[i].text.trim(), completata: _prove[i])),
      dataRaggiunta: _tutteCompletate ? (_data ?? DateTime.now()) : null,
    );
    widget.onSalva(aggiornata);
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
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(image: AssetImage(widget.specialita.imagePath), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(widget.specialita.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend'))),
              ],
            ),
            const SizedBox(height: 32),
            _buildLabel("LE TRE PROVE"),
            const SizedBox(height: 12),
            ...List.generate(3, (i) {
              final sbloccata = i == 0 || _prove[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: sbloccata ? 1.0 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _prove[i] ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _prove[i] ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: sbloccata ? () => setState(() => _prove[i] = !_prove[i]) : null,
                          child: Icon(_prove[i] ? Icons.check_circle_rounded : Icons.circle_outlined, color: _prove[i] ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text("${i + 1}ª", style: TextStyle(color: _prove[i] ? const Color(0xFF14532D) : const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _proveCtrl[i],
                            enabled: sbloccata,
                            style: TextStyle(color: _prove[i] ? const Color(0xFF14532D) : const Color(0xFF475569), fontSize: 14, fontFamily: 'Lexend'),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: "Descrizione della prova...", hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14)),
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
              child: _tutteCompletate ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildLabel("DATA DI ASSEGNAZIONE"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selezionaData,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBBF7D0))),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: Color(0xFF16A34A), size: 20),
                          const SizedBox(width: 12),
                          Text(_data != null ? "${_data!.day.toString().padLeft(2, '0')}/${_data!.month.toString().padLeft(2, '0')}/${_data!.year}" : "Seleziona data...", style: const TextStyle(color: Color(0xFF14532D), fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                        ],
                      ),
                    ),
                  ),
                ],
              ) : const SizedBox.shrink(),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: TextButton.icon(onPressed: _confermaElimina, icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)), label: const Text("ELIMINA", style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w800, fontFamily: 'Lexend')))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: ElevatedButton(onPressed: _salva, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2660), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), child: const Text("SALVA", style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Lexend')))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confermaElimina() async {
    final bool? ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("Elimina Specialità", style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w900)), content: Text("Sei sicuro di voler eliminare \"${widget.specialita.nome}\"?", style: const TextStyle(fontFamily: 'Lexend')), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("ANNULLA", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF94A3B8)))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("ELIMINA", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE11D48), fontWeight: FontWeight.w800)))]));
    if (ok == true) widget.onElimina();
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')));
}

// --- SHEET AGGIUNGI SPECIALITÀ ---

class _AggiungiSpecialitaSheet extends StatefulWidget {
  final Function(Specialita) onAggiungi;
  const _AggiungiSpecialitaSheet({required this.onAggiungi});

  @override
  State<_AggiungiSpecialitaSheet> createState() => _AggiungiSpecialitaSheetState();
}

class _AggiungiSpecialitaSheetState extends State<_AggiungiSpecialitaSheet> {
  String? _nomeSelezionato;
  final List<TextEditingController> _proveCtrl = List.generate(3, (_) => TextEditingController());

  static const List<String> _tutteLeSpecialita = [
    'Allevatore', 'Alpinista', 'Amico degli animali', 'Amico del quartiere', 'Archeologo', 'Artigiano', 'Artista di strada', 'Astronomo', 'Atleta', 'Attore', 'Battelliere', 'Boscaiolo', 'Botanico', 'Campeggiatore', 'Canoista', 'Cantante', 'Carpentiere navale', 'Ciclista', 'Collezionista', 'Coltivatore', 'Corrispondente', 'Corrispondente radio', 'Cuoco', 'Danzatore', 'Disegnatore', 'Elettricista', 'Elettronico', 'Esperto del computer', 'Europeista', 'Falegname', 'Fa tutto', 'Folclorista', 'Fotografo', 'Giardiniere', 'Giocattolaio', 'Grafico', 'Guida', 'Guida marina', 'Hebertista', 'Idraulico', 'Infermiere', 'Interprete', 'Lavoratore in cuoio', 'Maestro dei giochi', 'Maestro dei nodi', 'Meccanico', 'Modellista', 'Muratore', 'Musicista', 'Naturalista', 'Nuotatore', 'Osservatore', 'Osservatore meteo', 'Pescatore', 'Pompiere', 'Redattore', 'Regista', 'Sarto', 'Scenografo', 'Segnalatore', 'Servizio della Parola', 'Servizio liturgico', 'Servizio missionario', 'Topografo', 'Velista',
  ];

  @override
  void dispose() {
    for (var c in _proveCtrl) { c.dispose(); }
    super.dispose();
  }

  void _apriSelettore() {
    JambSearchPicker.show(
      context,
      titolo: "Scegli Specialità",
      voci: _tutteLeSpecialita,
      selezionato: _nomeSelezionato,
      itemAssetPathBuilder: (v) => 'assets/specialita/${v.toLowerCase().replaceAll(' ', '_')}.jpg',
      onSeleziona: (v) {
        setState(() => _nomeSelezionato = v);
        Navigator.of(context).pop();
      },
    );
  }

  void _conferma() {
    if (_nomeSelezionato == null) return;
    widget.onAggiungi(Specialita(nome: _nomeSelezionato!, prove: List.generate(3, (i) => Prova(descrizione: _proveCtrl[i].text.trim(), completata: false))));
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
            const SizedBox(height: 24),
            const Text("Nuova Specialità", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend')),
            const SizedBox(height: 24),
            _buildLabel("QUALE SPECIALITÀ VUOI INIZIARE?"),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _apriSelettore,
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [Expanded(child: Text(_nomeSelezionato ?? "Seleziona dal catalogo...", style: TextStyle(fontFamily: 'Lexend', fontSize: 15, color: _nomeSelezionato != null ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)))), const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20)])),
            ),
            if (_nomeSelezionato != null) ...[
              const SizedBox(height: 32),
              _buildLabel("DEFINISCI LE 3 PROVE"),
              const SizedBox(height: 12),
              ...List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1D2660)), child: Center(child: Text("${i + 1}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)))), const SizedBox(width: 14), Expanded(child: TextField(controller: _proveCtrl[i], style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontFamily: 'Lexend'), decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: "Descrizione prova...")))])),
              )),
            ],
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _nomeSelezionato == null ? null : _conferma, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2660), foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFFE2E8F0), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), child: const Text("INIZIA SPECIALITÀ", style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Lexend')))),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')));
}
