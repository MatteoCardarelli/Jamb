import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamb/domain/entities/transazione.dart';

class AddTransactionViewModel extends ChangeNotifier {
  bool isUscita = true;
  final TextEditingController amountController = TextEditingController(text: "0,00");
  final FocusNode amountFocus = FocusNode();

  DateTime selectedDate = DateTime.now();
  String selectedCategory = "Quote";
  String noteText = "";
  
  XFile? receiptFile; // Usiamo XFile che è cross-platform (Web/Mobile)
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = ["Quote", "Materiale", "Attività", "Sede", "Trasporti", "Altro"];

  @override
  void dispose() {
    amountController.dispose();
    amountFocus.dispose();
    super.dispose();
  }

  void setUscita(bool val) {
    isUscita = val;
    amountFocus.unfocus();
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setNote(String note) {
    noteText = note;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? selected = await _picker.pickImage(source: source);
      if (selected != null) {
        receiptFile = selected;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Errore durante la selezione dell'immagine: $e");
    }
  }

  Transazione? buildTransaction() {
    final double? importo = double.tryParse(amountController.text.replaceAll(',', '.'));
    if (importo == null || importo == 0) return null;

    return Transazione(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titolo: noteText.isEmpty ? (isUscita ? "Uscita" : "Entrata") : noteText,
      importo: importo,
      isUscita: isUscita,
      categoria: _mapCategory(selectedCategory),
      data: selectedDate,
      note: noteText,
      percorsoRicevuta: receiptFile?.path,
    );
  }

  Categoria _mapCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'materiale':
        return Categoria.materiale;
      case 'attività':
        return Categoria.attivita;
      case 'trasporti':
        return Categoria.trasporto;
      case 'sede':
        return Categoria.sede;
      case 'quote':
        return Categoria.quote;
      default:
        return Categoria.altro;
    }
  }
}
