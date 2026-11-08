import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/bilancio.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_app_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';

/// Schermata di un bilancio: scelta dell'anno scout sopra i [contenuti], con
/// gli stati di caricamento ed errore.
class SchermataBilancio extends StatelessWidget {
  final String titolo;
  final bool caricamento;
  final String? errore;
  final VoidCallback onRiprova;
  final List<String> anni;
  final String annoScelto;
  final ValueChanged<String> onAnno;
  final List<Widget> contenuti;

  const SchermataBilancio({
    super.key,
    required this.titolo,
    required this.caricamento,
    required this.errore,
    required this.onRiprova,
    required this.anni,
    required this.annoScelto,
    required this.onAnno,
    required this.contenuti,
  });

  @override
  Widget build(BuildContext context) {
    final messaggio = errore;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: JambAppBar(titolo: titolo),
      body: SafeArea(
        top: false,
        child: caricamento
            ? const Center(child: CircularProgressIndicator())
            : messaggio != null
                ? JambStatoErrore(messaggio: messaggio, onRiprova: onRiprova)
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final anno in anni)
                            JambChipFiltro(
                              etichetta: anno,
                              selezionato: anno == annoScelto,
                              onTap: () => onAnno(anno),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...contenuti,
                    ],
                  ),
      ),
    );
  }
}

/// Riga di un bilancio: una voce e il suo importo in centesimi.
class RigaImporto extends StatelessWidget {
  final String voce;
  final int centesimi;
  final bool forte;

  const RigaImporto(this.voce, this.centesimi, {super.key, this.forte = false});

  @override
  Widget build(BuildContext context) {
    final stile = TextStyle(
      fontFamily: 'Lexend',
      fontSize: forte ? 15 : 14,
      fontWeight: forte ? FontWeight.w800 : FontWeight.w500,
      color: const Color(0xFF1E293B),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(voce, style: stile)),
          Text('€ ${importoLeggibile(centesimi)}', style: stile),
        ],
      ),
    );
  }
}

/// Saldo iniziale, entrate e uscite per categoria e saldo finale.
class RiepilogoBilancio extends StatelessWidget {
  final Bilancio bilancio;

  const RiepilogoBilancio(this.bilancio, {super.key});

  List<Widget> _perCategoria(Map<Categoria, int> importi, String vuoto, String totale, int somma) => [
        if (importi.isEmpty) JambTestoVuoto(vuoto),
        for (final c in Categoria.values)
          if (importi[c] case final importo?) RigaImporto(c.etichetta, importo),
        const Divider(),
        RigaImporto(totale, somma, forte: true),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        JambRiquadro(
          titolo: 'Saldo',
          children: [
            RigaImporto('Saldo iniziale', bilancio.saldoIniziale),
            RigaImporto('Saldo finale', bilancio.saldoFinale, forte: true),
          ],
        ),
        const SizedBox(height: 12),
        JambRiquadro(
          titolo: 'Entrate',
          children: _perCategoria(
              bilancio.entrate, "Nessuna entrata nell'anno.", 'Totale entrate', bilancio.totaleEntrate),
        ),
        const SizedBox(height: 12),
        JambRiquadro(
          titolo: 'Uscite',
          children: _perCategoria(
              bilancio.uscite, "Nessuna uscita nell'anno.", 'Totale uscite', bilancio.totaleUscite),
        ),
      ],
    );
  }
}
