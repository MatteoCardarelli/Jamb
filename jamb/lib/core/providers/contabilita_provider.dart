import 'package:flutter/material.dart';

/// Rappresenta una singola operazione finanziaria (Entrata o Uscita).
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isPositive;
  final String? notes;
  final String? imagePath;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isPositive,
    this.notes,
    this.imagePath,
  });
}

/// Gestore dello stato per tutta la sezione Contabilità dell'app.
/// Centralizza i dati per garantire coerenza tra Home e sezione dedicata.
class ContabilitaProvider extends ChangeNotifier {
  // --- DATI PRIVATI ---
  double _saldoAttuale = 450.00;
  final double _budgetMensile = 1000.00;
  
  final List<Transaction> _transactions = [
    Transaction(
      id: "1",
      title: "Quota S. Giorgio",
      amount: 150.00,
      date: DateTime.now(),
      category: "Quote",
      isPositive: true,
    ),
    Transaction(
      id: "2",
      title: "Materiale Pionerismo",
      amount: 36.10,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: "Materiale",
      isPositive: false,
    ),
  ];

  // --- GETTERS ---
  double get saldoAttuale => _saldoAttuale;
  double get budgetMensile => _budgetMensile;
  List<Transaction> get transactions => _transactions;
  
  /// Calcola la percentuale di utilizzo del budget mensile
  double get budgetPercentage {
    double usciteMensili = _transactions
        .where((t) => !t.isPositive && t.date.month == DateTime.now().month)
        .fold(0, (sum, t) => sum + t.amount);
    return (usciteMensili / _budgetMensile).clamp(0.0, 1.0);
  }

  // --- AZIONI ---

  /// Aggiunge una nuova transazione e aggiorna il saldo
  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction); // Aggiunge in testa alla lista
    
    if (transaction.isPositive) {
      _saldoAttuale += transaction.amount;
    } else {
      _saldoAttuale -= transaction.amount;
    }
    
    notifyListeners();
  }
}
