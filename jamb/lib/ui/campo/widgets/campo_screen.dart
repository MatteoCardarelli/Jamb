import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/campo.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/domain/repositories/campo_repository.dart';
import 'package:jamb/ui/campo/view_model/campo_view_model.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riga_contatto.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_scelta_persone.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_schermata_elenco.dart';

/// Organizzazione di un campo (US18): pattuglie, compiti e contatti.
class CampoScreen extends StatelessWidget {
  final String campoId;

  const CampoScreen({super.key, required this.campoId});

  /// Apre l'organizzazione del campo [campoId].
  static Future<void> apri(BuildContext context, String campoId) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CampoScreen(campoId: campoId)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CampoViewModel(context.read<ICampoRepository>(), campoId),
      child: const CampoView(),
    );
  }
}

/// Contenuto dell'organizzazione del campo.
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

  Future<void> _scegliDate(
    BuildContext context,
    CampoViewModel viewModel,
  ) async {
    final periodo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('it', 'IT'),
    );
    if (periodo != null && context.mounted) {
      await eseguiConFeedback(
        context,
        () => viewModel.impostaDate(periodo.start, periodo.end),
      );
    }
  }

  void _menuPattuglia(
    BuildContext context,
    CampoViewModel viewModel,
    Pattuglia p,
  ) {
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

  Future<void> _eliminaPattuglia(
    BuildContext context,
    CampoViewModel viewModel,
    Pattuglia p,
  ) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: 'Elimina pattuglia',
      messaggio: 'Vuoi eliminare "${p.nome}" con tutti i suoi compiti?',
    );
    if (conferma && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.eliminaPattuglia(p));
    }
  }

  Future<void> _componenti(
    BuildContext context,
    CampoViewModel viewModel,
    Pattuglia p,
  ) async {
    final scelti = await scegliPersone(
      context,
      titolo: p.nome,
      candidati: viewModel.staff,
      iniziali: viewModel.membriDi(p).map((m) => m.id).toSet(),
      testoVuoto: 'Nessun capo in questo staff.',
    );
    if (scelti != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.salvaMembri(p, scelti));
    }
  }

  /// Chiede chi è il contatto e poi il suo numero.
  Future<void> _nuovoContatto(
    BuildContext context,
    CampoViewModel viewModel,
  ) async {
    final etichetta = await JambDialogs.chiediNome(
      context,
      titolo: 'Nuovo contatto',
      icona: Icons.contact_phone_outlined,
      conferma: 'AVANTI',
      etichetta: 'Chi è e a cosa serve',
      suggerimento: 'Es. Guardia forestale, permessi',
      valida: erroreTestoCampo,
    );
    if (etichetta == null || !context.mounted) return;
    final telefono = await JambDialogs.chiediNome(
      context,
      titolo: etichetta,
      icona: Icons.phone_outlined,
      conferma: 'SALVA',
      etichetta: 'Telefono',
      suggerimento: 'Es. 333 1234567',
      tastiera: TextInputType.phone,
      valida: erroreTelefono,
    );
    if (telefono != null && context.mounted) {
      await eseguiConFeedback(
        context,
        () => viewModel.creaContatto(etichetta, telefono),
      );
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

    return JambSchermataElenco(
      titolo: 'Campo',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      children: campo == null
          ? const [
              JambTestoVuoto(
                'Questo campo non esiste più.',
                icona: Icons.park_outlined,
                centrato: true,
              ),
            ]
          : [
              JambRiquadro(
                titolo: campo.titolo,
                children: [
                  Text(
                    [
                      campo.tipo.etichetta,
                      if (campo.annoScout.isNotEmpty) campo.annoScout,
                    ].join(' · '),
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campo.luogo.isEmpty ? 'Luogo da definire' : campo.luogo,
                    style: const TextStyle(fontFamily: 'Lexend', fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _periodo(campo),
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: viewModel.avanzamento.frazione,
                    color: const Color(0xFF1B5E20),
                    backgroundColor: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viewModel.avanzamento.fatti} compiti fatti su ${viewModel.avanzamento.totali}',
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  JambPulsanteSecondario(
                    icona: Icons.title_rounded,
                    etichetta: 'Titolo',
                    onTap: () => _chiedi(
                      context,
                      titolo: 'Titolo',
                      etichetta: 'Titolo',
                      suggerimento: 'Es. Campo estivo 2027',
                      iniziale: campo.titolo,
                      salva: viewModel.rinominaCampo,
                    ),
                  ),
                  const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              JambRiquadro(
                titolo: 'Contatti',
                children: [
                  if (viewModel.contatti.isEmpty)
                    const JambTestoVuoto('Nessun contatto.'),
                  for (final c in viewModel.contatti)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: JambRigaContatto(
                        etichetta: c.etichetta,
                        telefono: c.telefono,
                        onElimina: () => eseguiConFeedback(
                          context,
                          () => viewModel.eliminaContatto(c),
                        ),
                      ),
                    ),
                  JambPulsanteSecondario(
                    icona: Icons.add_call,
                    etichetta: 'Aggiungi un contatto',
                    onTap: () => _nuovoContatto(context, viewModel),
                  ),
                ],
              ),
              for (final p in viewModel.pattuglie) ...[
                const SizedBox(height: 16),
                _RiquadroPattuglia(
                  pattuglia: p,
                  membri: viewModel.membriDi(p),
                  onComponenti: () => _componenti(context, viewModel, p),
                  compiti: viewModel.compitiDi(p),
                  onMenu: () => _menuPattuglia(context, viewModel, p),
                  onAvanza: (c) => eseguiConFeedback(
                    context,
                    () => viewModel.avanzaStato(c),
                  ),
                  onElimina: (c) => eseguiConFeedback(
                    context,
                    () => viewModel.eliminaCompito(c),
                  ),
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
    );
  }
}

/// Una pattuglia con i suoi compiti; toccando lo stato si passa al successivo.
class _RiquadroPattuglia extends StatelessWidget {
  final Pattuglia pattuglia;
  final List<MembroUnita> membri;
  final VoidCallback onComponenti;
  final List<CompitoCampo> compiti;
  final VoidCallback onMenu;
  final ValueChanged<CompitoCampo> onAvanza;
  final ValueChanged<CompitoCampo> onElimina;
  final VoidCallback onNuovo;

  const _RiquadroPattuglia({
    required this.pattuglia,
    required this.membri,
    required this.onComponenti,
    required this.compiti,
    required this.onMenu,
    required this.onAvanza,
    required this.onElimina,
    required this.onNuovo,
  });

  (IconData, Color) _aspetto(StatoCompito stato) => switch (stato) {
    StatoCompito.daFare => (
      Icons.radio_button_unchecked,
      const Color(0xFF94A3B8),
    ),
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
          membri.isEmpty
              ? const JambTestoVuoto('Nessun componente.')
              : Text(
                  membri.map((m) => m.nome).join(', '),
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
          const SizedBox(height: 8),
          JambPulsanteSecondario(
            icona: Icons.group_outlined,
            etichetta: 'Componenti',
            onTap: onComponenti,
          ),
          const SizedBox(height: 8),
          if (compiti.isEmpty) const JambTestoVuoto('Nessun compito.'),
          for (final c in compiti)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconButton(
                tooltip: c.stato.etichetta,
                icon: Icon(_aspetto(c.stato).$1, color: _aspetto(c.stato).$2),
                onPressed: () => onAvanza(c),
              ),
              title: Text(
                c.titolo,
                style: const TextStyle(fontFamily: 'Lexend', fontSize: 15),
              ),
              subtitle: Text(
                c.stato.etichetta,
                style: const TextStyle(fontFamily: 'Lexend', fontSize: 12),
              ),
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
