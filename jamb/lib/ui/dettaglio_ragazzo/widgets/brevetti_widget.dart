import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/progresso.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_search_picker.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/dettaglio_ragazzo/view_model/dettaglio_ragazzo_view_model.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/pannello_progressione.dart';

String _immagine(String nome) => immagineProgressione('brevetti', nome);

/// Brevetti di un ragazzo, con i pannelli per aggiungerli e modificarli.
class BrevettiWidget extends StatelessWidget {
  final List<Brevetto> brevetti;

  const BrevettiWidget({super.key, required this.brevetti});

  String _sottotitolo(Brevetto b, DettaglioRagazzoViewModel viewModel) {
    if (b.isPosseduto) return 'ottenuto il ${dataInCifre(b.dataConseguimento!)}';
    final completate = (viewModel.progressoBrevetto(b.nome) * 4).toInt();
    if (completate < 4) return '$completate di 4 specialità completate';
    return 'Specialità ok · prova finale mancante';
  }

  Color _coloreSottotitolo(Brevetto b, DettaglioRagazzoViewModel viewModel) {
    if (b.isPosseduto) return const Color(0xFF16A34A);
    return viewModel.progressoBrevetto(b.nome) >= 1.0
        ? const Color(0xFFF59E0B)
        : const Color(0xFF94A3B8);
  }

  void _apriDettaglio(BuildContext context, int index, DettaglioRagazzoViewModel viewModel) {
    apriPannelloProgressione(
      context,
      (ctx) => _EditBrevettoSheet(
        brevetto: brevetti[index],
        viewModel: viewModel,
        onSalva: (aggiornato) =>
            eseguiConFeedback(context, () => viewModel.modificaBrevetto(index, aggiornato)),
        onElimina: () => eseguiConFeedback(context, () => viewModel.rimuoviBrevetto(index)),
      ),
    );
  }

  void _apriAggiungi(BuildContext context, DettaglioRagazzoViewModel viewModel) {
    apriPannelloProgressione(
      context,
      (ctx) => _AggiungiBrevettoSheet(
        onAggiungi: (nuovo) async {
          var aggiunto = true;
          final salvato = await eseguiConFeedback(context, () async {
            aggiunto = await viewModel.aggiungiBrevetto(nuovo);
          });
          if (salvato && !aggiunto && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Questo ragazzo ha già questo brevetto in corso!')),
            );
          }
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DettaglioRagazzoViewModel>();

    return JambRiquadro(
      titolo: 'Brevetti',
      children: [
        if (brevetti.isEmpty)
          const JambTestoVuoto('Nessun brevetto in corso.')
        else
          for (var i = 0; i < brevetti.length; i++)
            RigaProgressione(
              immagine: _immagine(brevetti[i].nome.name),
              titolo: brevetti[i].nome.name,
              sottotitolo: _sottotitolo(brevetti[i], viewModel),
              coloreSottotitolo: _coloreSottotitolo(brevetti[i], viewModel),
              conseguita: brevetti[i].isPosseduto,
              divisore: i > 0,
              onTap: () => _apriDettaglio(context, i, viewModel),
            ),
        const SizedBox(height: 20),
        JambPulsanteSecondario(
          icona: Icons.stars_rounded,
          etichetta: 'Aggiungi brevetto',
          onTap: () => _apriAggiungi(context, viewModel),
        ),
      ],
    );
  }
}

class _EditBrevettoSheet extends StatefulWidget {
  final Brevetto brevetto;
  final DettaglioRagazzoViewModel viewModel;
  final ValueChanged<Brevetto> onSalva;
  final VoidCallback onElimina;
  const _EditBrevettoSheet({
    required this.brevetto,
    required this.viewModel,
    required this.onSalva,
    required this.onElimina,
  });

  @override
  State<_EditBrevettoSheet> createState() => _EditBrevettoSheetState();
}

class _EditBrevettoSheetState extends State<_EditBrevettoSheet> {
  late bool _provaFinale;
  DateTime? _data;

  @override
  void initState() {
    super.initState();
    _provaFinale = widget.brevetto.provaFinaleSuperata;
    _data = widget.brevetto.dataConseguimento;
  }

  bool get _tuttiPrerequisiti => widget.viewModel.progressoBrevetto(widget.brevetto.nome) >= 1.0;

  bool get _ottenuto => _tuttiPrerequisiti && _provaFinale;

  void _salva() {
    widget.onSalva(widget.brevetto.copyWith(
      provaFinaleSuperata: _provaFinale,
      dataConseguimento: _ottenuto ? (_data ?? DateTime.now()) : null,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.brevetto.nome.name;
    final specialita = widget.viewModel.scout.progresso.specialita;
    return PannelloProgressione(
      children: [
        TitoloProgressione(immagine: _immagine(nome), titolo: nome),
        const SizedBox(height: 32),
        const EtichettaProgressione('LE SPECIALITÀ RICHIESTE'),
        const SizedBox(height: 12),
        for (final richiesta in widget.brevetto.nome.specialitaCorrelate)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RigaSpunta(
              testo: richiesta.name,
              completata: specialita.any((s) => s.nome == richiesta && s.isPosseduta),
            ),
          ),
        const SizedBox(height: 16),
        const EtichettaProgressione('PROVA FINALE DI COMPETENZA'),
        const SizedBox(height: 8),
        Opacity(
          opacity: _tuttiPrerequisiti ? 1.0 : 0.4,
          child: GestureDetector(
            onTap: _tuttiPrerequisiti ? () => setState(() => _provaFinale = !_provaFinale) : null,
            child: RigaSpunta(
              testo: widget.brevetto.provaFinaleDescrizione ?? 'Prova finale',
              completata: _provaFinale,
            ),
          ),
        ),
        DataConseguimento(
          visibile: _ottenuto,
          etichetta: 'DATA DI OTTENIMENTO',
          data: _data,
          onCambia: (d) => setState(() => _data = d),
        ),
        const SizedBox(height: 40),
        AzioniProgressione(
          titoloConferma: 'Elimina Brevetto',
          nome: nome,
          onElimina: widget.onElimina,
          onSalva: _salva,
        ),
      ],
    );
  }
}

class _AggiungiBrevettoSheet extends StatefulWidget {
  final ValueChanged<Brevetto> onAggiungi;
  const _AggiungiBrevettoSheet({required this.onAggiungi});

  @override
  State<_AggiungiBrevettoSheet> createState() => _AggiungiBrevettoSheetState();
}

class _AggiungiBrevettoSheetState extends State<_AggiungiBrevettoSheet> {
  BrevettoNome? _nome;
  final _provaCtrl = TextEditingController();

  @override
  void dispose() {
    _provaCtrl.dispose();
    super.dispose();
  }

  void _apriSelettore() {
    JambSearchPicker.show(
      context,
      titolo: 'Scegli Brevetto',
      voci: BrevettoNome.values.map((e) => e.name).toList(),
      selezionato: _nome?.name,
      itemAssetPathBuilder: _immagine,
      onSeleziona: (v) {
        setState(() => _nome = BrevettoNome.values.byName(v));
        Navigator.of(context).pop();
      },
    );
  }

  void _conferma() {
    final prova = _provaCtrl.text.trim();
    widget.onAggiungi(Brevetto(
      nome: _nome!,
      provaFinaleDescrizione: prova.isEmpty ? 'Prova finale' : prova,
      specialitaCollegate: _nome!.specialitaCorrelate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PannelloProgressione(
      children: [
        const TitoloNuovaProgressione('Nuovo Brevetto'),
        const SizedBox(height: 24),
        const EtichettaProgressione('SELEZIONA IL BREVETTO'),
        SceltaDalCatalogo(
          scelta: _nome?.name,
          suggerimento: 'Scegli dal catalogo...',
          onTap: _apriSelettore,
        ),
        const SizedBox(height: 24),
        const EtichettaProgressione('PROVA FINALE'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: decorazioneRigaProgressione(false),
          child: TextField(
            controller: _provaCtrl,
            style: const TextStyle(fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: 'Es. Impresa di squadriglia...',
              hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
        const SizedBox(height: 32),
        PulsanteProgressione(
          etichetta: 'INIZIA BREVETTO',
          onPressed: _nome == null ? null : _conferma,
        ),
      ],
    );
  }
}
