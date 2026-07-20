import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jamb/core/categoria_evento_colori.dart';
import '../../../domain/repositories/evento_repository.dart';
import '../../../domain/repositories/obiettivo_repository.dart';
import '../view_model/crea_evento_view_model.dart';

/// Schermata per la creazione di un nuovo evento del calendario.
class CreaEventoScreen extends StatelessWidget {
  const CreaEventoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreaEventoViewModel(
        context.read<IEventoRepository>(),
        context.read<IObiettivoRepository>(),
      ),
      child: const _CreaEventoView(),
    );
  }
}

class _CreaEventoView extends StatelessWidget {
  const _CreaEventoView();

  Future<void> _selectDate(BuildContext context, DateTime initialDate, ValueChanged<DateTime> onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('it', 'IT'),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime initialDate, ValueChanged<DateTime> onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (picked != null) {
      final newDate = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
        picked.hour,
        picked.minute,
      );
      onSelected(newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreaEventoViewModel>();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nuovo Evento',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D2660)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D2660)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITOLO
            _buildLabel('Titolo Evento'),
            TextField(
              onChanged: viewModel.setTitolo,
              decoration: _inputDecoration('Es. Uscita di Squadriglia'),
            ),
            const SizedBox(height: 24),

            // LUOGO
            _buildLabel('Luogo'),
            TextField(
              onChanged: viewModel.setLuogo,
              decoration: _inputDecoration('Es. Val di Fassa', icon: Icons.location_on_outlined),
            ),
            const SizedBox(height: 24),

            // DATA INIZIO
            _buildLabel('Inizio'),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await _selectDate(context, viewModel.dataInizio, (d) {
                        viewModel.setDataInizio(DateTime(d.year, d.month, d.day, viewModel.dataInizio.hour, viewModel.dataInizio.minute));
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _boxDecoration(),
                      child: Text(dateFormat.format(viewModel.dataInizio)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await _selectTime(context, viewModel.dataInizio, viewModel.setDataInizio);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _boxDecoration(),
                      child: Text(timeFormat.format(viewModel.dataInizio)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // DATA FINE
            _buildLabel('Fine'),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await _selectDate(context, viewModel.dataFine, (d) {
                        viewModel.setDataFine(DateTime(d.year, d.month, d.day, viewModel.dataFine.hour, viewModel.dataFine.minute));
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _boxDecoration(),
                      child: Text(dateFormat.format(viewModel.dataFine)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await _selectTime(context, viewModel.dataFine, viewModel.setDataFine);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _boxDecoration(),
                      child: Text(timeFormat.format(viewModel.dataFine)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // CATEGORIE (domini degli obiettivi del Programma d'Unità + "Altro")
            _buildLabel('Categorie'),
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: viewModel.categorieDisponibili.map((cat) {
                  final isSelected = viewModel.categorieSelezionate.contains(cat);
                  final colore = coloreCategoria(cat);
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? colore : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: sfondoCategoria(cat),
                    backgroundColor: Colors.grey[200],
                    onSelected: (_) => viewModel.toggleCategoria(cat),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 48),

            // TASTO SALVA
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: viewModel.isValid ? () async {
                  await viewModel.salvaEvento();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2660),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('SALVA EVENTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF94A3B8)) : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1D2660), width: 2),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }
}
