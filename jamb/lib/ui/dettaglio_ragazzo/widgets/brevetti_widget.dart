import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/jamb_search_picker.dart';
import 'package:jamb/domain/entities/progresso.dart';
import 'package:jamb/ui/dettaglio_ragazzo/view_model/dettaglio_ragazzo_view_model.dart';

/// Widget per la visualizzazione e gestione dei Brevetti di un ragazzo.
/// Sincronizzato con il DettaglioRagazzoViewModel per la logica di calcolo e unicità.
class BrevettiWidget extends StatelessWidget {
  final List<Brevetto> brevetti;

  const BrevettiWidget({
    super.key, 
    required this.brevetti,
  });

  String _sottotitolo(Brevetto b, DettaglioRagazzoViewModel viewModel) {
    if (b.isPosseduto) {
      final d = b.dataConseguimento!;
      return "ottenuto il ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    }
    
    final progresso = viewModel.progressoBrevetto(b.nome);
    final count = (progresso * 4).toInt();

    if (count < 4) {
      return "$count di 4 specialità completate";
    }
    return "Specialità ok · prova finale mancante";
  }

  String _getImagePath(BrevettoNome nome) {
    final snakeCase = nome.name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}').replaceFirst('_', '');
    return 'assets/brevetti/$snakeCase.jpg';
  }

  void _apriDettaglio(BuildContext context, int index, DettaglioRagazzoViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditBrevettoSheet(
        brevetto: brevetti[index],
        viewModel: viewModel,
        onSalva: (aggiornato) => viewModel.modificaBrevetto(index, aggiornato),
        onElimina: () => viewModel.rimuoviBrevetto(index),
      ),
    );
  }

  void _apriAggiungi(BuildContext context, DettaglioRagazzoViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AggiungiBrevettoSheet(
        onAggiungi: (nuovo) async {
          final success = await viewModel.aggiungiBrevetto(nuovo);
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Questo ragazzo ha già questo brevetto in corso!")),
            );
          }
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DettaglioRagazzoViewModel>();
    
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
          if (brevetti.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Nessun brevetto in corso.", style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Lexend', fontSize: 14)))
          else
            ...List.generate(brevetti.length, (i) {
              final b = brevetti[i];
              final progresso = viewModel.progressoBrevetto(b.nome);
              
              return Column(
                children: [
                  if (i > 0) const Divider(color: Color(0xFFF1F5F9), height: 24, thickness: 1.5),
                  GestureDetector(
                    onTap: () => _apriDettaglio(context, i, viewModel),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(image: AssetImage(_getImagePath(b.nome)), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.nome.name, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                              const SizedBox(height: 2),
                              Text(_sottotitolo(b, viewModel), style: TextStyle(color: b.isPosseduto ? const Color(0xFF16A34A) : (progresso >= 1.0 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8)), fontSize: 13, fontWeight: b.isPosseduto ? FontWeight.w600 : FontWeight.w400, fontFamily: 'Lexend')),
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
            onTap: () => _apriAggiungi(context, viewModel),
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
  final DettaglioRagazzoViewModel viewModel;
  final Function(Brevetto) onSalva;
  final VoidCallback onElimina;
  const _EditBrevettoSheet({required this.brevetto, required this.viewModel, required this.onSalva, required this.onElimina});

  @override
  State<_EditBrevettoSheet> createState() => _EditBrevettoSheetState();
}

class _EditBrevettoSheetState extends State<_EditBrevettoSheet> {
  late bool _provaFinale;
  DateTime? _data;

  @override
  void initState() {
    super.initState();
    _provaFinale = widget.brevetto.provaFinaleSuperata;
    _data = widget.brevetto.dataConseguimento;
  }

  bool get _tuttiPrerequisiti => widget.viewModel.progressoBrevetto(widget.brevetto.nome) >= 1.0;
  
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
    final aggiornato = widget.brevetto.copyWith(
      provaFinaleSuperata: _provaFinale,
      dataConseguimento: _ottenuto ? (_data ?? DateTime.now()) : null,
    );
    widget.onSalva(aggiornato);
    Navigator.of(context).pop();
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
                Container(width: 56, height: 56, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), image: DecorationImage(image: AssetImage(_getImagePath(widget.brevetto.nome)), fit: BoxFit.cover))),
                const SizedBox(width: 16),
                Expanded(child: Text(widget.brevetto.nome.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend'))),
              ],
            ),
            const SizedBox(height: 32),
            _buildLabel("LE SPECIALITÀ RICHIESTE"),
            const SizedBox(height: 12),
            ...widget.brevetto.nome.specialitaCorrelate.map((sName) {
              final raggiunta = widget.viewModel.scout.progresso.specialita.any((s) => s.nome == sName && s.isPosseduta);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), 
                  decoration: BoxDecoration(
                    color: raggiunta ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC), 
                    borderRadius: BorderRadius.circular(14), 
                    border: Border.all(color: raggiunta ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0))
                  ), 
                  child: Row(
                    children: [
                      Icon(raggiunta ? Icons.check_circle_rounded : Icons.circle_outlined, color: raggiunta ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1), size: 24), 
                      const SizedBox(width: 14), 
                      Expanded(child: Text(sName.name, style: TextStyle(color: raggiunta ? const Color(0xFF14532D) : const Color(0xFF64748B), fontSize: 14, fontWeight: raggiunta ? FontWeight.w700 : FontWeight.w500, fontFamily: 'Lexend')))
                    ]
                  )
                ),
              );
            }),
            const SizedBox(height: 16),
            _buildLabel("PROVA FINALE DI COMPETENZA"),
            const SizedBox(height: 8),
            Opacity(
              opacity: _tuttiPrerequisiti ? 1.0 : 0.4,
              child: GestureDetector(
                onTap: _tuttiPrerequisiti ? () => setState(() => _provaFinale = !_provaFinale) : null,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), decoration: BoxDecoration(color: _provaFinale ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: _provaFinale ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0))), child: Row(children: [Icon(_provaFinale ? Icons.check_circle_rounded : Icons.circle_outlined, color: _provaFinale ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1), size: 24), const SizedBox(width: 14), Expanded(child: Text(widget.brevetto.provaFinaleDescrizione ?? "Prova finale", style: TextStyle(color: _provaFinale ? const Color(0xFF14532D) : const Color(0xFF64748B), fontSize: 14, fontWeight: _provaFinale ? FontWeight.w700 : FontWeight.w500, fontFamily: 'Lexend')))])),
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
    final bool? ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("Elimina Brevetto", style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w900)), content: Text("Sei sicuro di voler eliminare \"${widget.brevetto.nome.name}\"?", style: const TextStyle(fontFamily: 'Lexend')), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("ANNULLA", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF94A3B8)))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("ELIMINA", style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE11D48), fontWeight: FontWeight.w800)))]));
    if (ok == true) {
      widget.onElimina();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8, fontFamily: 'Lexend')));

  String _getImagePath(BrevettoNome nome) {
    final snakeCase = nome.name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}').replaceFirst('_', '');
    return 'assets/brevetti/$snakeCase.jpg';
  }
}

// --- SHEET AGGIUNGI BREVETTO ---

class _AggiungiBrevettoSheet extends StatefulWidget {
  final Function(Brevetto) onAggiungi;
  const _AggiungiBrevettoSheet({required this.onAggiungi});
  @override
  State<_AggiungiBrevettoSheet> createState() => _AggiungiBrevettoSheetState();
}

class _AggiungiBrevettoSheetState extends State<_AggiungiBrevettoSheet> {
  BrevettoNome? _nome;
  final _provaCtrl = TextEditingController();

  @override
  void dispose() { _provaCtrl.dispose(); super.dispose(); }

  void _apriSelettore() {
    JambSearchPicker.show(
      context,
      titolo: "Scegli Brevetto",
      voci: BrevettoNome.values.map((e) => e.name).toList(),
      selezionato: _nome?.name,
      itemAssetPathBuilder: (v) {
        final snakeCase = v.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}').replaceFirst('_', '');
        return 'assets/brevetti/$snakeCase.jpg';
      },
      onSeleziona: (v) {
        setState(() {
          _nome = BrevettoNome.values.byName(v);
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _conferma() {
    if (_nome == null) return;
    widget.onAggiungi(Brevetto(
      nome: _nome!, 
      provaFinaleDescrizione: _provaCtrl.text.trim().isEmpty ? "Prova finale" : _provaCtrl.text.trim(), 
      specialitaCollegate: _nome!.specialitaCorrelate,
    ));
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
            GestureDetector(onTap: _apriSelettore, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [Expanded(child: Text(_nome?.name ?? "Scegli dal catalogo...", style: TextStyle(fontFamily: 'Lexend', fontSize: 15, color: _nome != null ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)))), const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20)]))),
            const SizedBox(height: 24),
            _buildLabel("PROVA FINALE"), _buildTextField(_provaCtrl, "Es. Impresa di squadriglia..."),
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
