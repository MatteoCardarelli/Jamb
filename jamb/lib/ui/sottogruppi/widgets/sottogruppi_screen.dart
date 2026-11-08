import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/ruolo_display.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/domain/repositories/sottogruppo_repository.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_schermata_elenco.dart';
import 'package:jamb/ui/ragazzi/view_model/ragazzi_view_model.dart';
import 'package:jamb/ui/sottogruppi/view_model/sottogruppi_view_model.dart';

/// Gestione dei sottogruppi dell'unità attiva (US20): squadriglie o sestiglie,
/// Consiglio Capi, Alta Squadriglia o Consiglio della Rupe.
class SottogruppiScreen extends StatelessWidget {
  const SottogruppiScreen({super.key});

  /// Apre i sottogruppi; al ritorno rilegge i ragazzi, che mostrano il nome
  /// della loro squadriglia.
  static Future<void> apri(BuildContext context) async {
    final ragazzi = context.read<RagazziViewModel>();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SottogruppiScreen()));
    ragazzi.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionService>();
    return ChangeNotifierProvider(
      create: (context) => SottogruppiViewModel(
        context.read<ISottogruppoRepository>(),
        SottogruppiBranca.di(session.tipoBrancaAttiva),
      ),
      child: SottogruppiView(
        puoModificare: session.permessi.puoCambiareRuoloESquadriglia,
      ),
    );
  }
}

/// Contenuto della schermata; chi non è [puoModificare] la consulta soltanto.
class SottogruppiView extends StatelessWidget {
  final bool puoModificare;

  const SottogruppiView({super.key, required this.puoModificare});

  Future<void> _nuova(
    BuildContext context,
    SottogruppiViewModel viewModel,
  ) async {
    final nome = await JambDialogs.chiediNome(
      context,
      titolo: 'Nuova ${viewModel.branca.gruppo}',
      icona: Icons.flag_outlined,
      conferma: 'CREA',
      suggerimento: 'Es. Aquile',
      valida: viewModel.erroreNome,
    );
    if (nome != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.crea(nome));
    }
  }

  Future<void> _rinomina(
    BuildContext context,
    SottogruppiViewModel viewModel,
    Squadriglia s,
  ) async {
    final nome = await JambDialogs.chiediNome(
      context,
      titolo: 'Rinomina',
      icona: Icons.edit_outlined,
      conferma: 'SALVA',
      iniziale: s.nome,
      valida: (n) => viewModel.erroreNome(n, escludiId: s.id),
    );
    if (nome != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.rinomina(s, nome));
    }
  }

  Future<void> _urlo(
    BuildContext context,
    SottogruppiViewModel viewModel,
    Squadriglia s,
  ) async {
    final urlo = await JambDialogs.chiediNome(
      context,
      titolo: 'Urlo',
      icona: Icons.campaign_outlined,
      conferma: 'SALVA',
      iniziale: s.urlo,
      etichetta: 'Urlo',
      suggerimento: 'Es. Sempre pronte!',
    );
    if (urlo != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.impostaUrlo(s, urlo));
    }
  }

  void _menu(
    BuildContext context,
    SottogruppiViewModel viewModel,
    Squadriglia s,
  ) {
    mostraMenuJamb(
      context,
      titolo: s.nome,
      voci: (_) => [
        JambVoceMenu(
          icona: Icons.edit_outlined,
          etichetta: 'Rinomina',
          onTap: () => _rinomina(context, viewModel, s),
        ),
        JambVoceMenu(
          icona: Icons.campaign_outlined,
          etichetta: 'Urlo',
          onTap: () => _urlo(context, viewModel, s),
        ),
        if (s.attiva)
          JambVoceMenu(
            icona: Icons.visibility_off_outlined,
            etichetta: 'Disattiva',
            pericolosa: true,
            onTap: () =>
                eseguiConFeedback(context, () => viewModel.disattiva(s)),
          )
        else
          JambVoceMenu(
            icona: Icons.visibility_outlined,
            etichetta: 'Riattiva',
            onTap: () =>
                eseguiConFeedback(context, () => viewModel.riattiva(s)),
          ),
      ],
    );
  }

  Future<void> _modificaMembri(
    BuildContext context,
    SottogruppiViewModel viewModel,
    TipoSottogruppo tipo,
  ) async {
    final scelti = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _DialogoMembri(
        titolo: tipo.etichetta,
        candidati: viewModel.ragazzi,
        iniziali: viewModel.membriSottogruppo(tipo).map((m) => m.id).toSet(),
      ),
    );
    if (scelti != null && context.mounted) {
      await eseguiConFeedback(
        context,
        () => viewModel.salvaMembri(tipo, scelti),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SottogruppiViewModel>();
    final branca = viewModel.branca;

    return JambSchermataElenco(
      titolo: 'Sottogruppi',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.ricarica,
      children: [
        if (branca.vuota)
          const JambTestoVuoto(
            'Nessun sottogruppo per questa branca.',
            icona: Icons.groups_outlined,
            centrato: true,
          ),
        if (branca.gruppi != null)
          JambRiquadro(
            titolo: branca.gruppi,
            children: [
              if (viewModel.attive.isEmpty)
                JambTestoVuoto('Ancora nessuna ${branca.gruppo}.'),
              for (final s in viewModel.attive)
                _RigaSquadriglia(
                  squadriglia: s,
                  membri: viewModel.membriDella(s),
                  onTap: puoModificare
                      ? () => _menu(context, viewModel, s)
                      : null,
                ),
              for (final s in viewModel.disattivate)
                _RigaSquadriglia(
                  squadriglia: s,
                  membri: const [],
                  onTap: puoModificare
                      ? () => _menu(context, viewModel, s)
                      : null,
                ),
              if (puoModificare) ...[
                const SizedBox(height: 8),
                JambPulsanteSecondario(
                  icona: Icons.add_rounded,
                  etichetta: 'Nuova ${branca.gruppo}',
                  onTap: () => _nuova(context, viewModel),
                ),
              ],
            ],
          ),
        if (branca.consiglioCapi) ...[
          const SizedBox(height: 16),
          JambRiquadro(
            titolo: 'Consiglio Capi',
            children: [
              if (viewModel.consiglio.isEmpty)
                const JambTestoVuoto('Nessun componente.'),
              for (final m in viewModel.consiglio) _RigaMembro(m),
            ],
          ),
        ],
        for (final tipo in branca.scelti) ...[
          const SizedBox(height: 16),
          JambRiquadro(
            titolo: tipo.etichetta,
            children: [
              if (viewModel.membriSottogruppo(tipo).isEmpty)
                const JambTestoVuoto('Nessun componente.'),
              for (final m in viewModel.membriSottogruppo(tipo)) _RigaMembro(m),
              if (puoModificare) ...[
                const SizedBox(height: 8),
                JambPulsanteSecondario(
                  icona: Icons.group_add_outlined,
                  etichetta: 'Scegli i componenti',
                  onTap: () => _modificaMembri(context, viewModel, tipo),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Squadriglia con urlo e ragazzi; un tocco apre le azioni, se permesse.
class _RigaSquadriglia extends StatelessWidget {
  final Squadriglia squadriglia;
  final List<MembroUnita> membri;
  final VoidCallback? onTap;

  const _RigaSquadriglia({
    required this.squadriglia,
    required this.membri,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dettagli = [
      if (squadriglia.urlo.isNotEmpty) '«${squadriglia.urlo}»',
      if (!squadriglia.attiva) 'Disattivata',
      if (squadriglia.attiva)
        membri.isEmpty
            ? 'Nessun ragazzo'
            : membri.map((m) => m.nome).join(', '),
    ].join('\n');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        squadriglia.nome,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w800,
          color: squadriglia.attiva
              ? const Color(0xFF1E293B)
              : const Color(0xFF94A3B8),
        ),
      ),
      subtitle: Text(
        dettagli,
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 13,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: onTap == null
          ? null
          : const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
    );
  }
}

/// Nome e ruolo di un componente di un sottogruppo.
class _RigaMembro extends StatelessWidget {
  final MembroUnita membro;

  const _RigaMembro(this.membro);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              membro.nome,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            ruoloLabel(membro.ruolo),
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialogo per scegliere i componenti tra i ragazzi dell'unità; restituisce
/// gli id scelti, o `null` se si annulla.
class _DialogoMembri extends StatefulWidget {
  final String titolo;
  final List<MembroUnita> candidati;
  final Set<String> iniziali;

  const _DialogoMembri({
    required this.titolo,
    required this.candidati,
    required this.iniziali,
  });

  @override
  State<_DialogoMembri> createState() => _DialogoMembriState();
}

class _DialogoMembriState extends State<_DialogoMembri> {
  late final Set<String> _scelti = {...widget.iniziali};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.titolo,
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w900,
          color: Color(0xFF1D2660),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.candidati.isEmpty
            ? const JambTestoVuoto('Nessun ragazzo nell\'unità.')
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final m in widget.candidati)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _scelti.contains(m.id),
                      title: Text(
                        m.nome,
                        style: const TextStyle(fontFamily: 'Lexend'),
                      ),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _scelti.add(m.id);
                        } else {
                          _scelti.remove(m.id);
                        }
                      }),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ANNULLA'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_scelti),
          child: const Text('SALVA'),
        ),
      ],
    );
  }
}
