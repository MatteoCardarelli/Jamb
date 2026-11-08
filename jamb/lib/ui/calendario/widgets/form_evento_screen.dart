import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jamb/core/categoria_evento_colori.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';
import 'package:jamb/ui/core/widgets/jamb_errore_in_linea.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/calendario/widgets/modulistica_suggerita.dart';
import 'package:jamb/ui/calendario/widgets/ripetizione_ui.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';
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
      appBar: JambAppBar(
        titolo: viewModel.isModifica ? 'Modifica Evento' : 'Nuovo Evento',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CALENDARIO: si sceglie creando l'evento e poi non cambia
            if (!viewModel.isModifica) ...[
              JambEtichettaCampo('Calendario'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  JambChipFiltro(
                    etichetta: 'La mia unità',
                    selezionato: viewModel.livello == LivelloEvento.unita,
                    onTap: () => viewModel.setLivello(LivelloEvento.unita),
                  ),
                  JambChipFiltro(
                    etichetta: 'Co.Ca.',
                    selezionato: viewModel.livello == LivelloEvento.coca,
                    onTap: () => viewModel.setLivello(LivelloEvento.coca),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // TITOLO
            JambEtichettaCampo('Titolo Evento'),
            TextFormField(
              initialValue: viewModel.titolo,
              onChanged: viewModel.setTitolo,
              decoration: jambDecorazioneCampo('Es. Uscita di Squadriglia'),
            ),
            const SizedBox(height: 24),

            // LUOGO
            JambEtichettaCampo('Luogo'),
            TextFormField(
              initialValue: viewModel.luogo,
              onChanged: viewModel.setLuogo,
              decoration: jambDecorazioneCampo(
                'Es. Val di Fassa',
                icona: Icons.location_on_outlined,
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
            JambEtichettaCampo('Inizio'),
            _buildDataOra(
              context,
              viewModel.dataInizio,
              viewModel.setDataInizio,
              mostraOra: !viewModel.tuttoIlGiorno,
            ),
            const SizedBox(height: 24),

            // DATA FINE
            JambEtichettaCampo('Fine'),
            _buildDataOra(
              context,
              viewModel.dataFine,
              viewModel.setDataFine,
              mostraOra: !viewModel.tuttoIlGiorno,
            ),
            const SizedBox(height: 24),

            // SI RIPETE: si sceglie creando l'evento; in modifica si chiede al salvataggio
            if (!viewModel.isModifica) ...[
              JambEtichettaCampo('Si ripete'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in Ripetizione.values)
                    JambChipFiltro(
                      etichetta: r.etichetta,
                      selezionato: viewModel.ripetizione == r,
                      onTap: () => viewModel.setRipetizione(r),
                    ),
                ],
              ),
              if (viewModel.ripetizione != Ripetizione.mai) ...[
                const SizedBox(height: 16),
                JambEtichettaCampo('Fino al'),
                _buildDataOra(
                  context,
                  viewModel.finoAl,
                  viewModel.setFinoAl,
                  mostraOra: false,
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.anteprimaRipetizione,
                  style: TextStyle(
                    color: viewModel.numeroEventi == 0 ? const Color(0xFFB91C1C) : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ] else if (viewModel.inSerie) ...[
              Text(
                'Fa parte di una ripetizione: salvando potrai scegliere se modificare anche gli eventi successivi.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],

            // CATEGORIE (domini degli obiettivi del Programma d'Unità + "Altro")
            JambEtichettaCampo('Categorie'),
            if (viewModel.isLoading)
              const JambCaricamentoPiccolo()
            else ...[
              // Senza obiettivi caricati il form resta utilizzabile con "Altro".
              if (viewModel.haErrore)
                JambErroreInLinea(
                  messaggio:
                      'Categorie del Programma d\'Unità non disponibili: ${viewModel.errore}',
                  onRiprova: viewModel.ricaricaCategorie,
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

            const SizedBox(height: 32),

            // MODULISTICA: proposta solo creando un evento (come da mockup)
            if (!viewModel.isModifica) const ModulisticaSuggerita(),
          ],
        ),
      ),
      // TASTO SALVA: fisso in fondo, sopra la barra di sistema di Android.
      bottomNavigationBar: JambBarraInFondo(
        etichetta: 'SALVA EVENTO',
        icona: Icons.save_rounded,
        onPressed: viewModel.isValid ? () => _salva(context, viewModel) : null,
      ),
    );
  }

  Future<void> _salva(BuildContext context, FormEventoViewModel viewModel) async {
    var ambito = AmbitoSerie.soloQuesto;
    if (viewModel.inSerie) {
      final scelto = await chiediAmbitoSerie(context, azione: 'Modifica');
      if (scelto == null || !context.mounted) return;
      ambito = scelto;
    }

    Evento? evento;
    final salvato = await eseguiConFeedback(context, () async {
      evento = await viewModel.salvaEvento(ambito: ambito);
    });
    if (salvato && context.mounted) Navigator.pop(context, evento);
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

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }
}
