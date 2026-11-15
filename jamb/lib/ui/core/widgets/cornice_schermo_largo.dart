import 'package:flutter/material.dart';

/// Larghezza massima dell'app: oltre questa (computer, tablet in
/// orizzontale) le schermate restano larghe come un telefono, al centro.
const double larghezzaMassimaApp = 480;

/// Tiene l'app alla larghezza di un telefono sugli schermi larghi, per
/// esempio nella versione web aperta dal computer.
///
/// Le schermate sono disegnate per il telefono: allargate a tutto schermo
/// perderebbero le proporzioni. Anche `MediaQuery` riporta la larghezza
/// ridotta, così i widget che la leggono si comportano come su un telefono.
/// Fino a [larghezzaMassimaApp] non cambia nulla.
class CorniceSchermoLargo extends StatelessWidget {
  final Widget child;

  const CorniceSchermoLargo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= larghezzaMassimaApp) return child;

    return ColoredBox(
      color: const Color(0xFFE2E8F0),
      child: Center(
        child: Container(
          width: larghezzaMassimaApp,
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 32)],
          ),
          child: MediaQuery(
            data: media.copyWith(
              size: Size(larghezzaMassimaApp, media.size.height),
            ),
            child: ClipRect(child: child),
          ),
        ),
      ),
    );
  }
}
