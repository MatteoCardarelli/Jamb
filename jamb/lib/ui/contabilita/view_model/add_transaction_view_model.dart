import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddTransactionViewModel extends ChangeNotifier {
  bool isUscita = true;
  final TextEditingController amountController = TextEditingController(text: "0,00");
  final FocusNode amountFocus = FocusNode();

  DateTime selectedDate = DateTime.now();
  String selectedCategory = "Quote";
  String noteText = "";
  
  File? receiptImage;
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
        receiptImage = File(selected.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Errore durante la selezione dell'immagine: $e");
    }
  }

  void saveTransaction() {
    // Qui andrebbe la logica per salvare la transazione nel repository
    // Per ora facciamo solo il pop (gestito dalla View)
  }
}
