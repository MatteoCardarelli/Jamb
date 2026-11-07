import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/entities/transazione.dart';

/// Stato del form di inserimento transazione: importo, categoria, data, note
/// e ricevuta; costruisce l'entità [Transazione] da salvare.
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
      // Ridimensionata e compressa: una foto di uno scontrino resta leggibile
      // e sta comodamente sotto il limite del bucket delle ricevute.
      final XFile? selected = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 80,
      );
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
    );
  }

  /// Foto dello scontrino scelta, da archiviare al salvataggio (`null` se
  /// non è stata scelta). Il percorso sul dispositivo non viene salvato:
  /// sugli altri telefoni non servirebbe a nulla.
  Future<FileDaCaricare?> ricevutaDaCaricare() async {
    final file = receiptFile;
    if (file == null) return null;
    return FileDaCaricare(nome: file.name, byte: await file.readAsBytes());
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
