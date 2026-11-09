import 'package:flutter/material.dart';
import 'package:jamb/ui/core/formato.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';

const Color _blu = Color(0xFF1D2660);
const Color _rosso = Color(0xFFE11D48);
const Color _verde = Color(0xFF16A34A);
const Color _verdeScuro = Color(0xFF14532D);
const Color _verdeSfondo = Color(0xFFF0FDF4);
const Color _verdeBordo = Color(0xFFBBF7D0);
const Color _grigioSfondo = Color(0xFFF8FAFC);
const Color _grigioBordo = Color(0xFFE2E8F0);
const Color _grigioIcona = Color(0xFFCBD5E1);

/// Immagine della specialità o del brevetto [nome], nella cartella [cartella].
String immagineProgressione(String cartella, String nome) {
  final snakeCase = nome
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => '_${m.group(1)!.toLowerCase()}')
      .replaceFirst('_', '');
  return 'assets/$cartella/$snakeCase.jpg';
}

/// Sfondo e bordo delle righe dei pannelli, verdi quando [completata].
BoxDecoration decorazioneRigaProgressione(bool completata) => BoxDecoration(
      color: completata ? _verdeSfondo : _grigioSfondo,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: completata ? _verdeBordo : _grigioBordo),
    );

/// Apre dal basso un pannello di specialità o brevetti.
Future<void> apriPannelloProgressione(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: builder,
    );

/// Una specialità o un brevetto nell'elenco della scheda del ragazzo.
class RigaProgressione extends StatelessWidget {
  final String immagine;
  final String titolo;
  final String sottotitolo;
  final Color coloreSottotitolo;

  /// Sottotitolo in evidenza: la specialità o il brevetto è conseguito.
  final bool conseguita;

  /// `false` per la prima riga, che non ha il divisore sopra.
  final bool divisore;
  final VoidCallback onTap;

  const RigaProgressione({
    super.key,
    required this.immagine,
    required this.titolo,
    required this.sottotitolo,
    required this.coloreSottotitolo,
    required this.conseguita,
    required this.divisore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (divisore) const Divider(color: Color(0xFFF1F5F9), height: 24, thickness: 1.5),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              _Immagine(immagine, lato: 48, raggio: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titolo,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sottotitolo,
                      style: TextStyle(
                        color: coloreSottotitolo,
                        fontSize: 13,
                        fontWeight: conseguita ? FontWeight.w600 : FontWeight.w400,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _grigioIcona),
            ],
          ),
        ),
      ],
    );
  }
}

class _Immagine extends StatelessWidget {
  final String percorso;
  final double lato;
  final double raggio;
  const _Immagine(this.percorso, {required this.lato, required this.raggio});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lato,
      height: lato,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(raggio),
        image: DecorationImage(image: AssetImage(percorso), fit: BoxFit.cover),
      ),
    );
  }
}

/// Contenitore dei pannelli: angoli arrotondati, maniglia e scorrimento.
class PannelloProgressione extends StatelessWidget {
  final List<Widget> children;
  const PannelloProgressione({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, media.viewInsets.bottom + media.padding.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _grigioBordo,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Immagine e nome in cima al pannello di modifica.
class TitoloProgressione extends StatelessWidget {
  final String immagine;
  final String titolo;
  const TitoloProgressione({super.key, required this.immagine, required this.titolo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Immagine(immagine, lato: 56, raggio: 14),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            titolo,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _blu,
              fontFamily: 'Lexend',
            ),
          ),
        ),
      ],
    );
  }
}

/// Titolo del pannello di aggiunta.
class TitoloNuovaProgressione extends StatelessWidget {
  final String titolo;
  const TitoloNuovaProgressione(this.titolo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      titolo,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: _blu,
        fontFamily: 'Lexend',
      ),
    );
  }
}

/// Etichetta in maiuscolo di una sezione del pannello.
class EtichettaProgressione extends StatelessWidget {
  final String testo;
  const EtichettaProgressione(this.testo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        testo,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
          fontFamily: 'Lexend',
        ),
      ),
    );
  }
}

/// Riga con il segno di spunta: requisito raggiunto o prova superata.
class RigaSpunta extends StatelessWidget {
  final String testo;
  final bool completata;
  const RigaSpunta({super.key, required this.testo, required this.completata});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: decorazioneRigaProgressione(completata),
      child: Row(
        children: [
          IconaSpunta(completata: completata),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              testo,
              style: TextStyle(
                color: completata ? _verdeScuro : const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: completata ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cerchio vuoto, o con la spunta verde quando [completata].
class IconaSpunta extends StatelessWidget {
  final bool completata;
  const IconaSpunta({super.key, required this.completata});

  @override
  Widget build(BuildContext context) {
    return Icon(
      completata ? Icons.check_circle_rounded : Icons.circle_outlined,
      color: completata ? _verde : _grigioIcona,
      size: 24,
    );
  }
}

/// Campo che apre il catalogo; mostra la voce [scelta] o il [suggerimento].
class SceltaDalCatalogo extends StatelessWidget {
  final String? scelta;
  final String suggerimento;
  final VoidCallback onTap;

  const SceltaDalCatalogo({
    super.key,
    required this.scelta,
    required this.suggerimento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: decorazioneRigaProgressione(false),
        child: Row(
          children: [
            Expanded(
              child: Text(
                scelta ?? suggerimento,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 15,
                  color: scelta != null ? const Color(0xFF1E293B) : _grigioIcona,
                ),
              ),
            ),
            const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }
}

/// Data di conseguimento, che compare solo quando è [visibile].
class DataConseguimento extends StatelessWidget {
  final bool visibile;
  final String etichetta;
  final DateTime? data;
  final ValueChanged<DateTime> onCambia;

  const DataConseguimento({
    super.key,
    required this.visibile,
    required this.etichetta,
    required this.data,
    required this.onCambia,
  });

  Future<void> _scegli(BuildContext context) async {
    final scelta = await showDatePicker(
      context: context,
      initialDate: data ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: _blu)),
        child: child!,
      ),
    );
    if (scelta != null) onCambia(scelta);
  }

  @override
  Widget build(BuildContext context) {
    final giorno = data;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: !visibile
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                EtichettaProgressione(etichetta),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _scegli(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: decorazioneRigaProgressione(true),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: _verde, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          giorno != null ? dataInCifre(giorno) : 'Seleziona data...',
                          style: const TextStyle(
                            color: _verdeScuro,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Pulsante pieno a tutta larghezza che avvia una specialità o un brevetto.
class PulsanteProgressione extends StatelessWidget {
  final String etichetta;
  final VoidCallback? onPressed;
  const PulsanteProgressione({super.key, required this.etichetta, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _PulsantePieno(etichetta: etichetta, onPressed: onPressed),
    );
  }
}

class _PulsantePieno extends StatelessWidget {
  final String etichetta;
  final VoidCallback? onPressed;
  const _PulsantePieno({required this.etichetta, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _blu,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _grigioBordo,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(etichetta, style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Lexend')),
    );
  }
}

/// «Elimina», che chiede conferma e chiude il pannello, e «Salva».
class AzioniProgressione extends StatelessWidget {
  final String titoloConferma;
  final String nome;
  final VoidCallback onElimina;
  final VoidCallback onSalva;

  const AzioniProgressione({
    super.key,
    required this.titoloConferma,
    required this.nome,
    required this.onElimina,
    required this.onSalva,
  });

  Future<void> _confermaElimina(BuildContext context) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: titoloConferma,
      messaggio: 'Sei sicuro di voler eliminare "$nome"?',
    );
    if (!conferma) return;
    onElimina();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () => _confermaElimina(context),
            icon: const Icon(Icons.delete_outline_rounded, color: _rosso),
            label: const Text(
              'ELIMINA',
              style: TextStyle(color: _rosso, fontWeight: FontWeight.w800, fontFamily: 'Lexend'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _PulsantePieno(etichetta: 'SALVA', onPressed: onSalva)),
      ],
    );
  }
}
