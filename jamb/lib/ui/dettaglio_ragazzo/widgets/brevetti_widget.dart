import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_search_picker.dart';

// --- MODELLI DI DATI ---

/// Rappresenta una specialità richiesta come prerequisito per un brevetto.
class RequisitoBrevetto {
  String nomeSpecialita;
  bool raggiunta;
  RequisitoBrevetto({required this.nomeSpecialita, required this.raggiunta});
}

/// Rappresenta un Brevetto di competenza scout (E/G).
class Brevetto {
  final String nome;
  final List<RequisitoBrevetto> specialitaRichieste;
  final String provaFinaleDescrizione;
  final bool provaFinaleSuperata;
  final DateTime? dataOttenimento;

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

// --- WIDGET PRINCIPALE ---

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
    final int raggiunte = b.specialitaRichieste.where((s) => s.raggiunta).length;
    if (raggiunte < 4) return "$raggiunte di 4 specialità completate";
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
          const Text("Brevetti", style: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
          const SizedBox(height: 16),
          if (_brevetti.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Nessun brevetto in corso.", style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Lexend', fontSize: 14)))
          else
            ...List.generate(_brevetti.length, (i) {
              final b = _brevetti[i];
              final raggiunte = b.specialitaRichieste.where((s) => s.raggiunta).length;
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
                            image: DecorationImage(image: AssetImage(b.imagePath), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.nome, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                              const SizedBox(height: 2),
                              Text(_sottotitolo(b), style: TextStyle(color: b.ottenuto ? const Color(0xFF16A34A) : (raggiunte == 4 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8)), fontSize: 13, fontWeight: b.ottenuto ? FontWeight.w600 : FontWeight.w400, fontFamily: 'Lexend')),
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
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars_rounded, color: Color(0xFF1D2660), size: 18),
                  SizedBox(width: 8),
                  Text("Aggiungi brevetto", style: TextStyle(color: Color(0xFF1D2660), fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SHEET MODIFICA BREVETTO ---

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
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1D2660))), child: child!),
    );
    if (picked != null) setState(() => _data = picked);
  }

  void _salva() {
    final aggiornato = Brevetto(
      nome: widget.brevetto.nome,
      provaFinaleDescrizione: widget.brevetto.provaFinaleDescrizione,
      provaFinaleSuperata: _provaFinale,
      dataOttenimento: _ottenuto ? (_data ?? DateTime.now()) : null,
      specialitaRichieste: List.generate(4, (i) => RequisitoBrevetto(nomeSpecialita: widget.brevetto.specialitaRichieste[i].nomeSpecialita, raggiunta: _raggiunte[i])),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), image: DecorationImage(image: AssetImage(widget.brevetto.imagePath), fit: BoxFit.cover))),
                const SizedBox(width: 16),
                Expanded(child: Text(widget.brevetto.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend'))),
              ],
            ),
            const SizedBox(height: 32),
            _buildLabel("LE 4 SPECIALITÀ RICHIESTE"),
            const SizedBox(height: 12),
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _raggiunte[i] = !_raggiunte[i]),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: _raggiunte[i] ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: _raggiunte[i] ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0))), child: Row(children: [Icon(_raggiunte[i] ? Icons.check_circle_rounded : Icons.circle_outlined, color: _raggiunte[i] ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1), size: 24), const SizedBox(width: 14), Expanded(child: Text(widget.brevetto.specialitaRichieste[i].nomeSpecialita, style: TextStyle(color: _raggiunte[i] ? const Color(0xFF14532D) : const Color(0xFF64748B), fontSize: 14, fontWeight: _raggiunte[i] ? FontWeight.w700 : FontWeight.w500, fontFamily: 'Lexend')))])),
              ),
            )),
            const SizedBox(height: 16),
            _buildLabel("PROVA FINALE DI COMPETENZA"),
            const SizedBox(height: 8),
            Opacity(
              opacity: _tuttiPrerequisiti ? 1.0 : 0.4,
              child: GestureDetector(
                onTap: _tuttiPrerequisiti ? () => setState(() => _provaFinale = !_provaFinale) : null,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), decoration: BoxDecoration(color: _provaFinale ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: _provaFinale ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0))), child: Row(children: [Icon(_provaFinale ? Icons.check_circle_rounded : Icons.circle_outlined, color: _provaFinale ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1), size: 24), const SizedBox(width: 14), Expanded(child: Text(widget.brevetto.provaFinaleDescrizione, style: TextStyle(color: _provaFinale ? const Color(0xFF14532D) : const Color(0xFF64748B), fontSize: 14, fontWeight: _provaFinale ? FontWeight.w700 : FontWeight.w500, fontFamily: 'Lexend')))])),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _ottenuto ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildLabel("DATA DI OTTENIMENTO"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selezionaData,
                    child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBBF7D0))), child: Row(children: [const Icon(Icons.calendar_today_rounded, color: Color(0xFF16A34A), size: 20), const SizedBox(width: 12), Text(_data != null ? "${_data!.day.toString().padLeft(2, '0')}/${_data!.month.toString().padLeft(2, '0')}/${_data!.year}" : "Seleziona data...", style: const TextStyle(color: Color(0xFF14532D), fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Lexend'))])),
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
    final bool? ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("Elimina Brevetto", style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w900)), content: Text("Sei sicuro di voler eliminare \"${widget.brevetto.nome}\"?", style: const TextStyle(fontFamily: 'Lexend')), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("ANNULLA", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF94A3B8)))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("ELIMINA", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE11D48), fontWeight: FontWeight.w800)))]));
    if (ok == true) widget.onElimina();
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')));
}

// --- SHEET AGGIUNGI BREVETTO ---

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
    'Naturalista': ['Naturalista', 'Botanico', 'Osservatore meteo', 'Astronomo'], 'Artista': ['Artista di strada', 'Danzatore', 'Musicista', 'Attore'], 'Giornalista': ['Corrispondente', 'Fotografo', 'Redattore', 'Regista'], 'Grafico multimediale': ['Grafico', 'Fotografo', 'Esperto del computer', 'Scenografo'], 'Cittadino del mondo': ['Europeista', 'Interprete', 'Guida', 'Folclorista'], 'Liturgista': ['Servizio liturgico', 'Servizio della Parola', 'Servizio missionario', 'Musicista'], 'Animatore sportivo': ['Atleta', 'Hébertista', 'Nuotatore', 'Maestro dei giochi'], 'Guida alpina': ['Alpinista', 'Topografo', 'Campeggiatore', 'Hébertista'], 'Mani Abili': ['Falegname', 'Muratore', 'Elettricista', 'Artigiano'], 'Pioniere': ['Campeggiatore', 'Boscaiolo', 'Maestro dei nodi', 'Topografo'], 'Soccorritore': ['Infermiere', 'Pompiere', 'Nuotatore', 'Atleta'], 'Sherpa': ['Alpinista', 'Boscaiolo', 'Campeggiatore', 'Naturalista'], 'Trappeur': ['Botanico', 'Pescatore', 'Naturalista', 'Campeggiatore'], 'Maestro delle Tecnologie': ['Esperto del computer', 'Elettronico', 'Elettricista', 'Modellista'], 'Esploratore delle acque': ['Nuotatore', 'Canoista', 'Velista', 'Guida marina'],
  };

  @override
  void dispose() { _provaCtrl.dispose(); for (final c in _sc) { c.dispose(); } super.dispose(); }

  void _apriSelettore() {
    JambSearchPicker.show(
      context,
      titolo: "Scegli Brevetto",
      voci: _brevetti,
      selezionato: _nome,
      itemAssetPathBuilder: (v) => 'assets/brevetti/${v.toLowerCase().replaceAll(' ', '_')}.jpg',
      onSeleziona: (v) {
        setState(() {
          _nome = v;
          final r = _req[v] ?? ['', '', '', ''];
          for (int i = 0; i < 4; i++) _sc[i].text = i < r.length ? r[i] : '';
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _conferma() {
    if (_nome == null) return;
    widget.onAggiungi(Brevetto(nome: _nome!, provaFinaleDescrizione: _provaCtrl.text.trim().isEmpty ? "Prova finale di brevetto" : _provaCtrl.text.trim(), specialitaRichieste: List.generate(4, (i) => RequisitoBrevetto(nomeSpecialita: _sc[i].text.trim().isNotEmpty ? _sc[i].text.trim() : 'Specialità ${i + 1}', raggiunta: false))));
  }

  @override
  Widget build(BuildContext context) {
    final bp = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bp + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text("Nuovo Brevetto", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend')),
            const SizedBox(height: 24),
            _buildLabel("SELEZIONA IL BREVETTO"),
            GestureDetector(onTap: _apriSelettore, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [Expanded(child: Text(_nome ?? "Scegli dal catalogo...", style: TextStyle(fontFamily: 'Lexend', fontSize: 15, color: _nome != null ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)))), const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20)]))),
            const SizedBox(height: 24),
            _buildLabel("PROVA FINALE"), _buildTextField(_provaCtrl, "Es. Impresa di squadriglia..."),
            const SizedBox(height: 24),
            _buildLabel("LE 4 SPECIALITÀ RICHIESTE"),
            if (_nome != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text("Requisiti ufficiali per $_nome", style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Lexend'))),
            ...List.generate(4, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1D2660)), child: Center(child: Text("${i + 1}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)))), const SizedBox(width: 14), Expanded(child: _buildTextField(_sc[i], "Nome specialità..."))]))),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _nome == null ? null : _conferma, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2660), foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFFE2E8F0), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), child: const Text("INIZIA BREVETTO", style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Lexend')))),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')));
  Widget _buildTextField(TextEditingController c, String h) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))), child: TextField(controller: c, style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)), decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: h, hintStyle: const TextStyle(color: Color(0xFFCBD5E1)))));
}
