import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/progresso.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_search_picker.dart';
import 'package:jamb/ui/dettaglio_ragazzo/view_model/dettaglio_ragazzo_view_model.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/pannello_progressione.dart';

String _immagine(String nome) => immagineProgressione('specialita', nome);

/// Specialità di un ragazzo, con i pannelli per aggiungerle e modificarle.
class SpecialitaWidget extends StatelessWidget {
  final List<Specialita> specialita;
  const SpecialitaWidget({super.key, required this.specialita});

  String _sottotitolo(Specialita s) {
    if (s.isPosseduta) return 'raggiunta il ${dataInCifre(s.dataConseguimento!)}';
    if (s.prove.isEmpty) return 'Nessuna prova definita';
    final idx = s.prove.indexWhere((p) => !p.isCompletato);
    if (idx == -1) return 'Tutte le prove completate';
    final descrizione = s.prove[idx].titolo.trim();
    return "${idx + 1}ª prova: ${descrizione.isNotEmpty ? descrizione : 'da definire'}";
  }

  void _apriDettaglio(BuildContext context, int index, DettaglioRagazzoViewModel viewModel) {
    apriPannelloProgressione(
      context,
      (ctx) => _EditSpecialitaSheet(
        specialita: specialita[index],
        onSalva: (aggiornata) =>
            eseguiConFeedback(context, () => viewModel.modificaSpecialita(index, aggiornata)),
        onElimina: () => eseguiConFeedback(context, () => viewModel.rimuoviSpecialita(index)),
      ),
    );
  }

  void _apriAggiungi(BuildContext context, DettaglioRagazzoViewModel viewModel) {
    apriPannelloProgressione(
      context,
      (ctx) => _AggiungiSpecialitaSheet(
        onAggiungi: (nuova) async {
          var aggiunta = true;
          final salvato = await eseguiConFeedback(context, () async {
            aggiunta = await viewModel.aggiungiSpecialita(nuova);
          });
          if (salvato && !aggiunta && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Questo ragazzo ha già questa specialità!')),
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
      titolo: 'Specialità Attive',
      children: [
        for (var i = 0; i < specialita.length; i++)
          RigaProgressione(
            immagine: _immagine(specialita[i].nome.name),
            titolo: specialita[i].nome.name,
            sottotitolo: _sottotitolo(specialita[i]),
            coloreSottotitolo:
                specialita[i].isPosseduta ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
            conseguita: specialita[i].isPosseduta,
            divisore: i > 0,
            onTap: () => _apriDettaglio(context, i, viewModel),
          ),
        const SizedBox(height: 20),
        JambPulsanteSecondario(
          icona: Icons.add_circle_outline_rounded,
          etichetta: 'Aggiungi specialità',
          onTap: () => _apriAggiungi(context, viewModel),
        ),
      ],
    );
  }
}

class _EditSpecialitaSheet extends StatefulWidget {
  final Specialita specialita;
  final ValueChanged<Specialita> onSalva;
  final VoidCallback onElimina;
  const _EditSpecialitaSheet({
    required this.specialita,
    required this.onSalva,
    required this.onElimina,
  });

  @override
  State<_EditSpecialitaSheet> createState() => _EditSpecialitaSheetState();
}

class _EditSpecialitaSheetState extends State<_EditSpecialitaSheet> {
  late List<bool> _proveStato;
  late List<TextEditingController> _proveCtrl;
  DateTime? _data;

  bool get _tutteCompletate => _proveStato.every((p) => p);

  @override
  void initState() {
    super.initState();
    _proveStato = widget.specialita.prove.map((p) => p.isCompletato).toList();
    _proveCtrl = widget.specialita.prove.map((p) => TextEditingController(text: p.titolo)).toList();
    _data = widget.specialita.dataConseguimento;

    while (_proveStato.length < 3) {
      _proveStato.add(false);
      _proveCtrl.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _proveCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  void _salva() {
    widget.onSalva(Specialita(
      nome: widget.specialita.nome,
      prove: List.generate(
        3,
        (i) => Impegno(titolo: _proveCtrl[i].text.trim(), isCompletato: _proveStato[i]),
      ),
      dataConseguimento: _tutteCompletate ? (_data ?? DateTime.now()) : null,
    ));
    Navigator.of(context).pop();
  }

  Widget _riga(int i) {
    final sbloccata = i == 0 || _proveStato[i - 1];
    final fatta = _proveStato[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: sbloccata ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: decorazioneRigaProgressione(fatta),
          child: Row(
            children: [
              GestureDetector(
                onTap: sbloccata ? () => setState(() => _proveStato[i] = !fatta) : null,
                child: IconaSpunta(completata: fatta),
              ),
              const SizedBox(width: 12),
              Text(
                '${i + 1}ª',
                style: TextStyle(
                  color: fatta ? const Color(0xFF14532D) : const Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _proveCtrl[i],
                  enabled: sbloccata,
                  style: TextStyle(
                    color: fatta ? const Color(0xFF14532D) : const Color(0xFF475569),
                    fontSize: 14,
                    fontFamily: 'Lexend',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Descrizione della prova...',
                    hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.specialita.nome.name;
    return PannelloProgressione(
      children: [
        TitoloProgressione(immagine: _immagine(nome), titolo: nome),
        const SizedBox(height: 32),
        const EtichettaProgressione('LE TRE PROVE'),
        const SizedBox(height: 12),
        for (var i = 0; i < 3; i++) _riga(i),
        DataConseguimento(
          visibile: _tutteCompletate,
          etichetta: 'DATA DI ASSEGNAZIONE',
          data: _data,
          onCambia: (d) => setState(() => _data = d),
        ),
        const SizedBox(height: 40),
        AzioniProgressione(
          titoloConferma: 'Elimina Specialità',
          nome: nome,
          onElimina: widget.onElimina,
          onSalva: _salva,
        ),
      ],
    );
  }
}

class _AggiungiSpecialitaSheet extends StatefulWidget {
  final ValueChanged<Specialita> onAggiungi;
  const _AggiungiSpecialitaSheet({required this.onAggiungi});

  @override
  State<_AggiungiSpecialitaSheet> createState() => _AggiungiSpecialitaSheetState();
}

class _AggiungiSpecialitaSheetState extends State<_AggiungiSpecialitaSheet> {
  SpecialitaNome? _nome;
  final List<TextEditingController> _proveCtrl = List.generate(3, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _proveCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  void _apriSelettore() {
    JambSearchPicker.show(
      context,
      titolo: 'Scegli Specialità',
      voci: SpecialitaNome.values.map((e) => e.name).toList(),
      selezionato: _nome?.name,
      itemAssetPathBuilder: _immagine,
      onSeleziona: (v) {
        setState(() => _nome = SpecialitaNome.values.byName(v));
        Navigator.of(context).pop();
      },
    );
  }

  void _conferma() {
    widget.onAggiungi(Specialita(
      nome: _nome!,
      prove: List.generate(
        3,
        (i) => Impegno(titolo: _proveCtrl[i].text.trim(), isCompletato: false),
      ),
    ));
  }

  Widget _riga(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: decorazioneRigaProgressione(false),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1D2660)),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: _proveCtrl[i],
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontFamily: 'Lexend'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Descrizione prova...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PannelloProgressione(
      children: [
        const TitoloNuovaProgressione('Nuova Specialità'),
        const SizedBox(height: 24),
        const EtichettaProgressione('QUALE SPECIALITÀ VUOI INIZIARE?'),
        const SizedBox(height: 8),
        SceltaDalCatalogo(
          scelta: _nome?.name,
          suggerimento: 'Seleziona dal catalogo...',
          onTap: _apriSelettore,
        ),
        if (_nome != null) ...[
          const SizedBox(height: 32),
          const EtichettaProgressione('DEFINISCI LE 3 PROVE'),
          for (var i = 0; i < 3; i++) _riga(i),
        ],
        const SizedBox(height: 32),
        PulsanteProgressione(
          etichetta: 'INIZIA SPECIALITÀ',
          onPressed: _nome == null ? null : _conferma,
        ),
      ],
    );
  }
}
