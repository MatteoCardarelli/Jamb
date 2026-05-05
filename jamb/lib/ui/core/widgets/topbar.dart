import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Barra superiore personalizzata con design distintivo Jamb.
/// Presenta una forma a "tuffo" (dip) al centro che ospita il logo AGESCI,
/// icone profilo e notifiche, e informazioni sull'utente corrente.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(106);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double defaultBarHeight = 70.0;
    const double dipRadius = 36.0; // Raggio della curvatura centrale
    final double totalHeight = defaultBarHeight + statusBarHeight + dipRadius;
    const Color greenColor = Color(0xFF2F4F39); // Colore istituzionale verde scout

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // SFONDO SAGOMATO CON OMBRA
          Container(
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: const TopBarShape(),
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          
          // CONTENUTO DELLA BARRA (Avatar, Info Utente, Icone)
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            height: defaultBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Avatar Utente (SVG)
                  SvgPicture.asset(
                    'assets/icons/profilo.svg',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 10),
                  
                  // Info Utente: Nome e Totem
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matteo',
                        style: TextStyle(
                          color: greenColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      Text(
                        'Quokka Impassibile',
                        style: TextStyle(
                          color: greenColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  // Icone d'azione (Opzioni e Notifiche)
                  SvgPicture.asset(
                    'assets/icons/opzioni.svg',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 24),
                  SvgPicture.asset(
                    'assets/icons/notifiche.svg',
                    width: 28,
                    height: 28,
                  ),
                ],
              ),
            ),
          ),
          
          // LOGO AGESCI: Posizionato esattamente nella curvatura centrale
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: dipRadius * 2,
                height: dipRadius * 2,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/logo_agesci.svg',
                    width: 66,
                    height: 66,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Definizione della forma geometrica personalizzata per la TopBar.
/// Crea un rettangolo con un semicerchio scavato verso il basso al centro.
class TopBarShape extends ShapeBorder {
  const TopBarShape();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    const double dipRadius = 36.0;
    const double dipDiameter = dipRadius * 2;
    
    // Calcola l'altezza della parte rettangolare prima della curva
    final double bottomY = rect.height - dipRadius;
    
    path.lineTo(0, bottomY);
    
    // Disegna la linea fino all'inizio del semicerchio centrale
    double startX = (rect.width - dipDiameter) / 2;
    path.lineTo(startX, bottomY);
    
    // Crea la curvatura verso il basso (dip)
    path.arcToPoint(
      Offset(startX + dipDiameter, bottomY),
      radius: const Radius.circular(dipRadius),
      clockwise: false,
    );
    
    // Prosegue fino alla fine del rettangolo
    path.lineTo(rect.width, bottomY);
    path.lineTo(rect.width, 0);
    path.close();
    
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
