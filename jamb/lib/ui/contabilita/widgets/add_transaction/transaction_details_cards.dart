import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/jamb_search_picker.dart';
import 'package:jamb/ui/contabilita/view_model/add_transaction_view_model.dart';

/// Sezione centrale della vista AddTransaction.
/// Gestisce la selezione della Data, della Categoria e l'inserimento delle Note.
class TransactionDetailsCards extends StatelessWidget {
  const TransactionDetailsCards({super.key});

  /// Mostra il calendario ufficiale per la scelta della data
  Future<void> _selectDate(BuildContext context, AddTransactionViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1D2660))),
        child: child!,
      ),
    );
    if (picked != null) {
      viewModel.setDate(picked);
    }
  }

  /// Apre il selettore di ricerca core per le categorie
  void _showCategoryPicker(BuildContext context, AddTransactionViewModel viewModel) {
    JambSearchPicker.show(
      context,
      titolo: "Seleziona Categoria",
      voci: viewModel.categories,
      selezionato: viewModel.selectedCategory,
      onSeleziona: (v) {
        viewModel.setCategory(v);
        Navigator.pop(context);
      },
    );
  }

  /// Mostra un pannello per l'inserimento della causale (Note)
  void _showNotesPicker(BuildContext context, AddTransactionViewModel viewModel) {
    final TextEditingController notesPopupCtrl = TextEditingController(text: viewModel.noteText);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Causale / Note", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2660), fontFamily: 'Lexend')),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: notesPopupCtrl,
                  autofocus: true,
                  maxLines: 3,
                  style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(hintText: "Scrivi qui la descrizione...", border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.setNote(notesPopupCtrl.text.trim());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2660),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("CONFERMA", style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddTransactionViewModel>();

    return Column(
      children: [
        // CARD DATA
        _buildClickableCard(
          label: "DATA OPERAZIONE",
          icon: Icons.calendar_today_rounded,
          text: DateFormat('dd/MM/yyyy').format(viewModel.selectedDate),
          onTap: () => _selectDate(context, viewModel),
        ),
        const SizedBox(height: 16),
        
        // CARD CATEGORIA
        _buildClickableCard(
          label: "CATEGORIA",
          icon: Icons.category_rounded,
          text: viewModel.selectedCategory,
          suffixIcon: Icons.keyboard_arrow_down_rounded,
          onTap: () => _showCategoryPicker(context, viewModel),
        ),
        const SizedBox(height: 16),
        
        // CARD NOTE
        _buildClickableCard(
          label: "CAUSALE / NOTE",
          icon: Icons.description_rounded,
          text: viewModel.noteText.isEmpty ? "Descrizione della spesa..." : viewModel.noteText,
          isPlaceholder: viewModel.noteText.isEmpty,
          onTap: () => _showNotesPicker(context, viewModel),
        ),
      ],
    );
  }

  /// Costruisce una card interattiva con label superiore e campo di testo evidenziato
  Widget _buildClickableCard({
    required String label,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    IconData? suffixIcon,
    bool isPlaceholder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF1D2660)),
                const SizedBox(width: 8),
                Text(
                  label, 
                  style: const TextStyle(color: Color(0xFF1D2660), fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: 0.5)
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15, 
                        color: isPlaceholder ? const Color(0xFF94A3B8) : const Color(0xFF1E293B), 
                        fontFamily: 'Lexend', 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  if (suffixIcon != null) Icon(suffixIcon, color: const Color(0xFF94A3B8), size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
