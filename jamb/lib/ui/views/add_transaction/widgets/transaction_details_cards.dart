import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsCards extends StatefulWidget {
  const TransactionDetailsCards({super.key});

  @override
  State<TransactionDetailsCards> createState() => _TransactionDetailsCardsState();
}

class _TransactionDetailsCardsState extends State<TransactionDetailsCards> {
  DateTime selectedDate = DateTime.now();
  String selectedCategory = "Quote";
  String noteText = ""; // Testo memorizzato
  final TextEditingController _notesPopupCtrl = TextEditingController();
  
  final List<String> categories = ["Quote", "Materiale", "Attività", "Sede", "Trasporti", "Altro"];

  @override
  void dispose() {
    _notesPopupCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF000066),
              onPrimary: Colors.white,
              onSurface: Color(0xFF000066),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetContainer(
          title: "Seleziona Categoria",
          child: Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = cat);
                    Navigator.pop(context);
                  },
                  child: _buildSelectionItem(cat, isSelected),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showNotesPicker() {
    _notesPopupCtrl.text = noteText;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _buildBottomSheetContainer(
            title: "Inserisci Causale / Note",
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _notesPopupCtrl,
                    autofocus: true,
                    maxLines: 3,
                    style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1E293B)),
                    decoration: const InputDecoration(
                      hintText: "Scrivi qui la descrizione...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => noteText = _notesPopupCtrl.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000066),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("CONFERMA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildClickableCard(
          label: "DATA OPERAZIONE",
          icon: Icons.calendar_today_outlined,
          text: DateFormat('dd/MM/yyyy').format(selectedDate),
          onTap: () => _selectDate(context),
        ),
        const SizedBox(height: 16),
        _buildClickableCard(
          label: "CATEGORIA",
          icon: Icons.category_outlined,
          text: selectedCategory,
          suffixIcon: Icons.keyboard_arrow_down_rounded,
          onTap: _showCategoryPicker,
        ),
        const SizedBox(height: 16),
        _buildClickableCard(
          label: "CAUSALE / NOTE",
          icon: Icons.notes_rounded,
          text: noteText.isEmpty ? "Descrizione della spesa..." : noteText,
          isPlaceholder: noteText.isEmpty,
          onTap: _showNotesPicker,
        ),
      ],
    );
  }

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
                Icon(icon, size: 20, color: const Color(0xFF000066)),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Color(0xFF000066), fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: isPlaceholder ? const Color(0xFF94A3B8) : const Color(0xFF1E293B), fontFamily: 'Lexend', fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (suffixIcon != null) Icon(suffixIcon, color: const Color(0xFF64748B), size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetContainer({required String title, required Widget child}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF000066), fontFamily: 'Lexend')),
          const SizedBox(height: 24),
          child,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSelectionItem(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFF000066) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(color: isSelected ? const Color(0xFF000066) : const Color(0xFF64748B), fontSize: 16, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, fontFamily: 'Lexend')),
          if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF000066), size: 20),
        ],
      ),
    );
  }
}
