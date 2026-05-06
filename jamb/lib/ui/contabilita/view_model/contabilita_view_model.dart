import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';

/// Gestore dello stato per tutta la sezione Contabilità dell'app.
/// Centralizza i dati, gestisce l'ordinamento e calcola le statistiche reali.
/// Ascolta il repository per aggiornamenti reattivi.
class ContabilitaViewModel extends ChangeNotifier {
  final ITransazioneRepository _repository;
  
  List<Transazione> _transactions = [];
  bool _isLoading = true;

  ContabilitaViewModel(this._repository) {
    _repository.addListener(_caricaDati);
    _caricaDati();
  }

  @override
  void dispose() {
    _repository.removeListener(_caricaDati);
    super.dispose();
  }

  Future<void> _caricaDati() async {
    _isLoading = true;
    notifyListeners();
    
    final lista = await _repository.getTransazioni();
    
    // Ordina per data decrescente (più recenti in cima)
    lista.sort((a, b) => b.data.compareTo(a.data));
    
    _transactions = lista;
    _isLoading = false;
    notifyListeners();
  }

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  List<Transazione> get transactions => _transactions;

  /// Calcola il saldo totale (Entrate - Uscite)
  double get saldoAttuale {
    double entrate = _transactions.where((t) => !t.isUscita).fold(0.0, (sum, t) => sum + t.importo);
    double uscite = _transactions.where((t) => t.isUscita).fold(0.0, (sum, t) => sum + t.importo);
    return entrate - uscite;
  }

  /// Calcola il totale delle uscite
  double get totaleUscite => _transactions
      .where((t) => t.isUscita)
      .fold(0.0, (sum, t) => sum + t.importo);

  /// Ritorna la distribuzione delle uscite per categoria (valore tra 0.0 e 1.0)
  Map<Categoria, double> get ripartizioneSpese {
    final uscite = _transactions.where((t) => t.isUscita);
    final totale = totaleUscite;
    
    if (totale == 0) return {};
    
    Map<Categoria, double> map = {};
    for (var cat in Categoria.values) {
      final sommaCat = uscite.where((t) => t.categoria == cat).fold(0.0, (sum, t) => sum + t.importo);
      if (sommaCat > 0) {
        map[cat] = sommaCat / totale;
      }
    }
    return map;
  }

  // --- AZIONI ---

  Future<void> addTransaction(Transazione transazione) async {
    await _repository.salvaTransazione(transazione);
    // Non serve ricaricare qui, l'addListener lo farà in automatico
  }

  Future<void> removeTransaction(String id) async {
    await _repository.eliminaTransazione(id);
  }
}
