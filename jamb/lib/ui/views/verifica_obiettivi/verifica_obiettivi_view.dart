import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';
import 'package:jamb/ui/views/verifica_obiettivi/widgets/edit_obiettivo_dialog.dart';
import 'package:jamb/ui/views/verifica_obiettivi/widgets/obiettivo_card.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';

class VerificaObiettiviView extends StatefulWidget {
  final List<Obiettivo> obiettivi;

  const VerificaObiettiviView({
    super.key,
    required this.obiettivi,
  });

  @override
  State<VerificaObiettiviView> createState() => _VerificaObiettiviViewState();
}

class _VerificaObiettiviViewState extends State<VerificaObiettiviView> {
  late List<Obiettivo> _currentObiettivi;

  @override
  void initState() {
    super.initState();
    // Create a local mutable copy of the passed list
    _currentObiettivi = List.from(widget.obiettivi);
  }

  void _updateScore(int index, int newScore) {
    setState(() {
      _currentObiettivi[index] = _currentObiettivi[index].copyWith(grado: newScore);
    });
  }

  Future<void> _openEditDialog(int index) async {
    final target = _currentObiettivi[index];
    final updatedObiettivo = await showDialog<Obiettivo>(
      context: context,
      builder: (context) => EditObiettivoDialog(obiettivo: target),
    );

    if (updatedObiettivo != null) {
      setState(() {
        _currentObiettivi[index] = updatedObiettivo;
      });
    }
  }

  void _saveAndReturn() {
    Navigator.of(context).pop(_currentObiettivi);
  }

  @override
  Widget build(BuildContext context) {
    return EmptyBackgroundScreen(
      currentIndex: 0, // Icona home piena
      child: Stack(
        children: [
          // List of Objectives
          Positioned.fill(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 200),
              itemCount: _currentObiettivi.length,
              itemBuilder: (context, index) {
                return ObiettivoCard(
                  obiettivo: _currentObiettivi[index],
                  onScoreChanged: (score) => _updateScore(index, score),
                  onEditTap: () => _openEditDialog(index),
                );
              },
            ),
          ),
          
          // Bottom Action Bar (Floating)
          Positioned(
            bottom: 130, // bottom 130 alza i pulsanti sopra la nav bar
            left: 20,
            right: 20,
            child: Row(
              children: [
                const BackActionButton(),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveAndReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00005C), // Deep dark blue
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Salva Verifica di Staff",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
