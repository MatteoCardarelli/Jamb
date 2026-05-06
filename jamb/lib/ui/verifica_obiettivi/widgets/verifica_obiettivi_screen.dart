import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/verifica_obiettivi/view_model/verifica_obiettivi_view_model.dart';
import 'package:jamb/ui/verifica_obiettivi/widgets/edit_obiettivo_dialog.dart';
import 'package:jamb/ui/verifica_obiettivi/widgets/obiettivo_card.dart';

/// Schermata per la verifica e la modifica degli obiettivi del programma d'unità.
/// Permette di aggiornare il grado di raggiungimento e i dettagli di ogni obiettivo.
class VerificaObiettiviScreen extends StatelessWidget {
  const VerificaObiettiviScreen({super.key});

  /// Apre il dialogo per modificare i testi e il colore dell'obiettivo
  Future<void> _openEditDialog(BuildContext context, int index) async {
    final viewModel = context.read<VerificaObiettiviViewModel>();
    final target = viewModel.obiettivi[index];
    
    // Calcoliamo i colori occupati dagli ALTRI obiettivi
    final occupiedColors = viewModel.getOccupiedColors(excludeId: target.id);

    final updatedObiettivo = await showDialog<Obiettivo>(
      context: context,
      builder: (context) => EditObiettivoDialog(
        obiettivo: target,
        usedColors: occupiedColors,
      ),
    );

    if (updatedObiettivo != null) {
      viewModel.updateObiettivo(index, updatedObiettivo);
    }
  }

  /// Crea un nuovo obiettivo vuoto e apre il dialogo di modifica
  Future<void> _addNewObiettivo(BuildContext context) async {
    final viewModel = context.read<VerificaObiettiviViewModel>();
    // Tutti i colori attualmente in uso sono "occupati" per il nuovo obiettivo
    final occupiedColors = viewModel.getOccupiedColors();

    final nuovo = Obiettivo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dominio: "NUOVO DOMINIO",
      descrizione: "Descrizione obiettivo...",
      icona: Icons.star_rounded,
      colore: const Color(0xFF1D2660),
      grado: 1,
      diarioDiBordo: "",
    );

    final creato = await showDialog<Obiettivo>(
      context: context,
      builder: (context) => EditObiettivoDialog(
        obiettivo: nuovo,
        usedColors: occupiedColors,
      ),
    );

    if (creato != null) {
      viewModel.addObiettivo(creato);
    }
  }

  /// Elimina un obiettivo dalla lista locale previa conferma
  Future<void> _deleteObiettivo(BuildContext context, int index) async {
    final viewModel = context.read<VerificaObiettiviViewModel>();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Elimina Obiettivo",
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D2660),
          ),
        ),
        content: const Text(
          "Sei sicuro di voler eliminare questo punto su cui lavorare? Questa azione non può essere annullata.",
          style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "ANNULLA",
              style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              "ELIMINA",
              style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      viewModel.removeObiettivo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VerificaObiettiviViewModel>();

    return EmptyBackgroundScreen(
      currentIndex: 0,
      child: Stack(
        children: [
          // AREA SCORREVOLE: Lista degli Obiettivi
          Positioned.fill(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 200),
              itemCount: viewModel.obiettivi.length,
              itemBuilder: (context, index) {
                return ObiettivoCard(
                  obiettivo: viewModel.obiettivi[index],
                  onScoreChanged: (score) => viewModel.updateScore(index, score),
                  onEditTap: () => _openEditDialog(context, index),
                  onDeleteTap: () => _deleteObiettivo(context, index),
                );
              },
            ),
          ),
          
          // BARRA DI AZIONE INFERIORE (Flottante)
          Positioned(
            bottom: 130,
            left: 20,
            right: 20,
            child: Row(
              children: [
                const BackActionButton(),
                const SizedBox(width: 12),
                
                // Pulsante AGGIUNGI
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: IconButton(
                    onPressed: () => _addNewObiettivo(context),
                    icon: const Icon(Icons.add_rounded, color: Color(0xFF1D2660), size: 28),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Pulsante di Salvataggio
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(viewModel.obiettivi),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00005C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 8),
                          const Text(
                            "Salva Verifica",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
