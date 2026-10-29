import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jamb/core/categoria_evento_colori.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import '../../../domain/entities/evento.dart';
import '../../../domain/repositories/evento_repository.dart';
import '../../../domain/repositories/obiettivo_repository.dart';
import '../view_model/form_evento_view_model.dart';

/// Schermata per creare un evento del calendario o modificare [eventoEsistente].
///
/// Alla chiusura dopo un salvataggio restituisce l'[Evento] salvato.
class FormEventoScreen extends StatelessWidget {
  final Evento? eventoEsistente;

  /// Giorno da cui parte un nuovo evento (es. quello selezionato nel calendario).
  final DateTime? giorno;

  const FormEventoScreen({super.key, this.eventoEsistente, this.giorno});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FormEventoViewModel(
        context.read<IEventoRepository>(),
        context.read<IObiettivoRepository>(),
        eventoEsistente: eventoEsistente,
        giorno: giorno,
      ),
      child: const _FormEventoView(),
    );
  }
}

class _FormEventoView extends StatelessWidget {
  const _FormEventoView();

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    ValueChanged<DateTime> onSelected,
  ) async {
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

  Future<void> _selectTime(
    BuildContext context,
    DateTime initialDate,
    ValueChanged<DateTime> onSelected,
  ) async {
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
    final viewModel = context.watch<FormEventoViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          viewModel.isModifica ? 'Modifica Evento' : 'Nuovo Evento',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2660),
          ),
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
            TextFormField(
              initialValue: viewModel.titolo,
              onChanged: viewModel.setTitolo,
              decoration: _inputDecoration('Es. Uscita di Squadriglia'),
            ),
            const SizedBox(height: 24),

            // LUOGO
            _buildLabel('Luogo'),
            TextFormField(
              initialValue: viewModel.luogo,
              onChanged: viewModel.setLuogo,
              decoration: _inputDecoration(
                'Es. Val di Fassa',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // GIORNATA INTERA: nasconde gli orari
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tutto il giorno'),
              value: viewModel.tuttoIlGiorno,
              activeThumbColor: const Color(0xFF1D2660),
              onChanged: viewModel.setTuttoIlGiorno,
            ),
            const SizedBox(height: 8),

            // DATA INIZIO
            _buildLabel('Inizio'),
            _buildDataOra(
              context,
              viewModel.dataInizio,
              viewModel.setDataInizio,
              mostraOra: !viewModel.tuttoIlGiorno,
            ),
            const SizedBox(height: 24),

            // DATA FINE
            _buildLabel('Fine'),
            _buildDataOra(
              context,
              viewModel.dataFine,
              viewModel.setDataFine,
              mostraOra: !viewModel.tuttoIlGiorno,
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
            else ...[
              // Senza obiettivi caricati il form resta utilizzabile con "Altro".
              if (viewModel.haErrore)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Categorie del Programma d\'Unità non disponibili: ${viewModel.errore}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: viewModel.ricaricaCategorie,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: viewModel.categorieDisponibili.map((cat) {
                  final isSelected = viewModel.categorieSelezionate.contains(
                    cat,
                  );
                  final colore = coloreCategoria(cat);
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? colore : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: sfondoCategoria(cat),
                    backgroundColor: Colors.grey[200],
                    onSelected: (_) => viewModel.toggleCategoria(cat),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 48),

            // TASTO SALVA
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: viewModel.isValid
                    ? () async {
                        Evento? evento;
                        final salvato = await eseguiConFeedback(
                          context,
                          () async {
                            evento = await viewModel.salvaEvento();
                          },
                        );
                        if (salvato && context.mounted) {
                          Navigator.pop(context, evento);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2660),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'SALVA EVENTO',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Riquadri per scegliere la data e, se [mostraOra], l'orario di [valore].
  Widget _buildDataOra(
    BuildContext context,
    DateTime valore,
    ValueChanged<DateTime> onChanged, {
    required bool mostraOra,
  }) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, valore, (d) {
              onChanged(
                DateTime(d.year, d.month, d.day, valore.hour, valore.minute),
              );
            }),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Text(DateFormat('dd/MM/yyyy').format(valore)),
            ),
          ),
        ),
        if (mostraOra) ...[
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(context, valore, onChanged),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: _boxDecoration(),
                child: Text(DateFormat('HH:mm').format(valore)),
              ),
            ),
          ),
        ],
      ],
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
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF94A3B8))
          : null,
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
