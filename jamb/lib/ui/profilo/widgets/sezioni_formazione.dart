import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamb/domain/entities/formazione.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';

const _stileTesto = TextStyle(fontFamily: 'Lexend', fontSize: 15, color: Color(0xFF1E293B));
const _stileSecondario = TextStyle(fontFamily: 'Lexend', fontSize: 13, color: Color(0xFF64748B));

/// Riquadro dell'iter formativo. Con [onTappa] una tappa si può toccare per
/// modificarla; senza, è in sola lettura.
class RiquadroIter extends StatelessWidget {
  final List<TappaCompiuta> tappe;
  final ValueChanged<TappaFormativa>? onTappa;

  const RiquadroIter({super.key, required this.tappe, this.onTappa});

  @override
  Widget build(BuildContext context) {
    final perTappa = {for (final t in tappe) t.tappa: t};
    final prossima = prossimaTappa(tappe);

    return JambRiquadro(
      titolo: 'Iter formativo',
      children: [
        for (final tappa in TappaFormativa.values)
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onTappa == null ? null : () => onTappa!(tappa),
            leading: Icon(
              perTappa.containsKey(tappa) ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: perTappa.containsKey(tappa) ? const Color(0xFF1B5E20) : const Color(0xFF94A3B8),
            ),
            title: Text(tappa.etichetta, style: _stileTesto),
            subtitle: Text(
              switch (perTappa[tappa]) {
                final compiuta? => DateFormat('dd/MM/yyyy').format(compiuta.data),
                null => tappa == prossima ? 'Prossima tappa' : 'Da fare',
              },
              style: _stileSecondario,
            ),
          ),
      ],
    );
  }
}

/// Riquadro del Progetto del Capo. Le callback mancanti lo rendono in sola
/// lettura, come quando lo consulta il Capo Gruppo.
class RiquadroProgetto extends StatelessWidget {
  final ProgettoCapo progetto;
  final String? nota;
  final VoidCallback? onModificaTesto;
  final ValueChanged<int>? onInvertiPasso;
  final ValueChanged<int>? onRimuoviPasso;
  final List<Widget> azioni;

  const RiquadroProgetto({
    super.key,
    required this.progetto,
    this.nota,
    this.onModificaTesto,
    this.onInvertiPasso,
    this.onRimuoviPasso,
    this.azioni = const [],
  });

  @override
  Widget build(BuildContext context) {
    return JambRiquadro(
      titolo: 'Progetto del Capo',
      children: [
        if (nota != null) ...[
          Text(nota!, style: _stileSecondario),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onModificaTesto,
          child: progetto.testo.trim().isEmpty
              ? const JambTestoVuoto('Il Progetto non è ancora stato scritto.')
              : Text(progetto.testo, style: _stileTesto),
        ),
        const SizedBox(height: 12),
        if (progetto.passi.isNotEmpty)
          Text('Passi: ${progetto.passiFatti} su ${progetto.passi.length}', style: _stileSecondario),
        for (final (i, passo) in progetto.passi.indexed)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: passo.fatto,
            onChanged: onInvertiPasso == null ? null : (_) => onInvertiPasso!(i),
            title: Text(passo.titolo, style: _stileTesto),
            secondary: onRimuoviPasso == null
                ? null
                : IconButton(
                    tooltip: 'Elimina passo',
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => onRimuoviPasso!(i),
                  ),
          ),
        ...azioni,
      ],
    );
  }
}
