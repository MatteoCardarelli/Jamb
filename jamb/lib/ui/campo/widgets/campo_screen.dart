import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/repositories/campo_repository.dart';
import 'package:jamb/ui/campo/view_model/campo_view_model.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';

/// Programmazione del campo dell'unità attiva (US18).
class CampoScreen extends StatelessWidget {
  const CampoScreen({super.key});

  /// Apre la programmazione del campo.
  static Future<void> apri(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CampoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CampoViewModel(context.read<ICampoRepository>()),
      child: const CampoView(),
    );
  }
}

/// Contenuto della programmazione del campo.
class CampoView extends StatelessWidget {
  const CampoView({super.key});

  Future<void> _chiedi(
    BuildContext context, {
    required String titolo,
    required String etichetta,
    required String suggerimento,
    required Future<void> Function(String) salva,
    String iniziale = '',
    bool obbligatorio = true,
  }) async {
    final testo = await JambDialogs.chiediNome(
      context,
      titolo: titolo,
      icona: Icons.edit_outlined,
      conferma: 'SALVA',
      iniziale: iniziale,
      etichetta: etichetta,
      suggerimento: suggerimento,
      valida: obbligatorio ? erroreTestoCampo : null,
    );
    if (testo != null && context.mounted) {
      await eseguiConFeedback(context, () => salva(testo));
    }
  }

  Future<void> _scegliDate(BuildContext context, CampoViewModel viewModel) async {
    final periodo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('it', 'IT'),
    );
    if (periodo != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.impostaDate(periodo.start, periodo.end));
    }
  }

  void _menuPattuglia(BuildContext context, CampoViewModel viewModel, Pattuglia p) {
    mostraMenuJamb(
      context,
      titolo: p.nome,
      voci: (_) => [
        JambVoceMenu(
          icona: Icons.edit_outlined,
          etichetta: 'Rinomina',
          onTap: () => _chiedi(
            context,
            titolo: 'Rinomina',
            etichetta: 'Nome',
            suggerimento: 'Es. Cucina',
            iniziale: p.nome,
            salva: (n) => viewModel.rinominaPattuglia(p, n),
          ),
        ),
        JambVoceMenu(
          icona: Icons.delete_outline_rounded,
          etichetta: 'Elimina',
          pericolosa: true,
          onTap: () => _eliminaPattuglia(context, viewModel, p),
        ),
      ],
    );
  }

  Future<void> _eliminaPattuglia(BuildContext context, CampoViewModel viewModel, Pattuglia p) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: 'Elimina pattuglia',
      messaggio: 'Vuoi eliminare "${p.nome}" con tutti i suoi compiti?',
    );
    if (conferma && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.eliminaPattuglia(p));
    }
  }

  String _periodo(Campo c) {
    final inizio = c.dataInizio;
    final fine = c.dataFine;
    if (inizio == null || fine == null) return 'Date da definire';
    final formato = DateFormat('dd/MM/yyyy');
    return '${formato.format(inizio)} - ${formato.format(fine)}';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CampoViewModel>();
    final campo = viewModel.campo;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const JambAppBar(titolo: 'Campo'),
      body: SafeArea(
        top: false,
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.haErrore
                ? JambStatoErrore(messaggio: viewModel.errore!, onRiprova: viewModel.ricarica)
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: campo == null
                        ? [
                            const JambTestoVuoto(
                              'Nessun campo per quest\'anno scout.',
                              icona: Icons.park_outlined,
                              centrato: true,
                            ),
                            JambPulsanteSecondario(
                              icona: Icons.add_rounded,
                              etichetta: 'Prepara il campo',
                              onTap: () => _chiedi(
                                context,
                                titolo: 'Nuovo campo',
                                etichetta: 'Titolo',
                                suggerimento: 'Es. Campo estivo 2027',
                                salva: viewModel.creaCampo,
                              ),
                            ),
                          ]
                        : [
                            JambRiquadro(
                              titolo: campo.titolo,
                              children: [
                                Text(
                                  campo.luogo.isEmpty ? 'Luogo da definire' : campo.luogo,
                                  style: const TextStyle(fontFamily: 'Lexend', fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(_periodo(campo), style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF64748B))),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: viewModel.avanzamento.frazione,
                                  color: const Color(0xFF1B5E20),
                                  backgroundColor: const Color(0xFFE2E8F0),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${viewModel.avanzamento.fatti} compiti fatti su ${viewModel.avanzamento.totali}',
                                  style: const TextStyle(fontFamily: 'Lexend', fontSize: 13, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 12),
                                JambPulsanteSecondario(
                                  icona: Icons.location_on_outlined,
                                  etichetta: 'Luogo',
                                  onTap: () => _chiedi(
                                    context,
                                    titolo: 'Luogo',
                                    etichetta: 'Luogo',
                                    suggerimento: 'Es. Val di Fassa',
                                    iniziale: campo.luogo,
                                    obbligatorio: false,
                                    salva: viewModel.impostaLuogo,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                JambPulsanteSecondario(
                                  icona: Icons.date_range_outlined,
                                  etichetta: 'Date',
                                  onTap: () => _scegliDate(context, viewModel),
                                ),
                              ],
                            ),
                            for (final p in viewModel.pattuglie) ...[
                              const SizedBox(height: 16),
                              _RiquadroPattuglia(
                                pattuglia: p,
                                compiti: viewModel.compitiDi(p),
                                onMenu: () => _menuPattuglia(context, viewModel, p),
                                onAvanza: (c) => eseguiConFeedback(context, () => viewModel.avanzaStato(c)),
                                onElimina: (c) => eseguiConFeedback(context, () => viewModel.eliminaCompito(c)),
                                onNuovo: () => _chiedi(
                                  context,
                                  titolo: 'Nuovo compito',
                                  etichetta: 'Compito',
                                  suggerimento: 'Es. Preparare il menu',
                                  salva: (t) => viewModel.creaCompito(p, t),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            JambPulsanteSecondario(
                              icona: Icons.group_add_outlined,
                              etichetta: 'Nuova pattuglia',
                              onTap: () => _chiedi(
                                context,
                                titolo: 'Nuova pattuglia',
                                etichetta: 'Nome',
                                suggerimento: 'Es. Cucina',
                                salva: viewModel.creaPattuglia,
                              ),
                            ),
                          ],
                  ),
      ),
    );
  }
}

/// Una pattuglia con i suoi compiti; toccando lo stato si passa al successivo.
class _RiquadroPattuglia extends StatelessWidget {
  final Pattuglia pattuglia;
  final List<CompitoCampo> compiti;
  final VoidCallback onMenu;
  final ValueChanged<CompitoCampo> onAvanza;
  final ValueChanged<CompitoCampo> onElimina;
  final VoidCallback onNuovo;

  const _RiquadroPattuglia({
    required this.pattuglia,
    required this.compiti,
    required this.onMenu,
    required this.onAvanza,
    required this.onElimina,
    required this.onNuovo,
  });

  (IconData, Color) _aspetto(StatoCompito stato) => switch (stato) {
        StatoCompito.daFare => (Icons.radio_button_unchecked, const Color(0xFF94A3B8)),
        StatoCompito.inCorso => (Icons.timelapse_rounded, const Color(0xFFE96A25)),
        StatoCompito.fatto => (Icons.check_circle_rounded, const Color(0xFF1B5E20)),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onMenu,
      child: JambRiquadro(
        titolo: pattuglia.nome,
        children: [
          if (compiti.isEmpty) const JambTestoVuoto('Nessun compito.'),
          for (final c in compiti)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconButton(
                tooltip: c.stato.etichetta,
                icon: Icon(_aspetto(c.stato).$1, color: _aspetto(c.stato).$2),
                onPressed: () => onAvanza(c),
              ),
              title: Text(c.titolo, style: const TextStyle(fontFamily: 'Lexend', fontSize: 15)),
              subtitle: Text(c.stato.etichetta, style: const TextStyle(fontFamily: 'Lexend', fontSize: 12)),
              trailing: IconButton(
                tooltip: 'Elimina compito',
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                onPressed: () => onElimina(c),
              ),
            ),
          const SizedBox(height: 8),
          JambPulsanteSecondario(
            icona: Icons.add_rounded,
            etichetta: 'Nuovo compito',
            onTap: onNuovo,
          ),
        ],
      ),
    );
  }
}
