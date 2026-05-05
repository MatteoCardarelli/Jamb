import 'package:flutter/material.dart';

/// Un selettore di ricerca generico visualizzato come BottomSheet.
/// Permette di filtrare una lista di stringhe e selezionarne una.
/// Supporta opzionalmente la visualizzazione di icone/immagini tramite un [itemAssetPathBuilder].
class JambSearchPicker extends StatefulWidget {
  /// Titolo visualizzato in alto nello sheet
  final String titolo;
  /// Lista completa delle voci selezionabili
  final List<String> voci;
  /// Voce attualmente selezionata (opzionale)
  final String? selezionato;
  /// Callback invocata alla selezione di una voce
  final ValueChanged<String> onSeleziona;
  /// Funzione opzionale che restituisce il path di un asset per ogni voce
  final String Function(String)? itemAssetPathBuilder;

  const JambSearchPicker({
    super.key,
    required this.titolo,
    required this.voci,
    required this.onSeleziona,
    this.selezionato,
    this.itemAssetPathBuilder,
  });

  /// Metodo statico helper per mostrare il picker come BottomSheet
  static Future<void> show(
    BuildContext context, {
    required String titolo,
    required List<String> voci,
    String? selezionato,
    required ValueChanged<String> onSeleziona,
    String Function(String)? itemAssetPathBuilder,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => JambSearchPicker(
        titolo: titolo,
        voci: voci,
        selezionato: selezionato,
        onSeleziona: onSeleziona,
        itemAssetPathBuilder: itemAssetPathBuilder,
      ),
    );
  }

  @override
  State<JambSearchPicker> createState() => _JambSearchPickerState();
}

class _JambSearchPickerState extends State<JambSearchPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<String> _filtrate;

  @override
  void initState() {
    super.initState();
    _filtrate = widget.voci;
    _searchCtrl.addListener(_filtraVoci);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filtraVoci() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtrate = widget.voci
          .where((v) => v.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 16),
      child: Column(
        children: [
          // MANIGLIA
          Container(
            width: 40, height: 4, 
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))
          ),
          const SizedBox(height: 24),
          
          // TITOLO
          Text(
            widget.titolo, 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend')
          ),
          const SizedBox(height: 16),
          
          // CAMPO DI RICERCA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(fontFamily: 'Lexend', fontSize: 15),
              decoration: const InputDecoration(
                border: InputBorder.none, 
                isDense: true,
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                hintText: "Cerca...",
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Lexend'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // LISTA RISULTATI
          Expanded(
            child: ListView.separated(
              itemCount: _filtrate.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9), height: 1),
              itemBuilder: (context, i) {
                final voce = _filtrate[i];
                final bool isSelected = voce == widget.selezionato;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  
                  // ICONA OPZIONALE
                  leading: widget.itemAssetPathBuilder != null 
                    ? Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(widget.itemAssetPathBuilder!(voce)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ) 
                    : null,
                  
                  title: Text(
                    voce, 
                    style: TextStyle(
                      fontFamily: 'Lexend', 
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1D2660) : const Color(0xFF475569),
                    )
                  ),
                  trailing: isSelected 
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20) 
                    : null,
                  onTap: () => widget.onSeleziona(voce),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
