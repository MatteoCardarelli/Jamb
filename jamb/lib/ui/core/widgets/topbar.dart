import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(106);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double defaultBarHeight = 70.0;
    const double dipRadius = 36.0; // The curve drops by 36px
    final double totalHeight = defaultBarHeight + statusBarHeight + dipRadius;
    const Color greenColor = Color(0xFF2F4F39);

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: const TopBarShape(),
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Ombra molto più visibile
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            height: defaultBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // User Avatar
                  SvgPicture.asset(
                    'assets/icons/profilo.svg',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 10),
                  // User info
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
                        ),
                      ),
                      Text(
                        'Quokka Impassibile',
                        style: TextStyle(
                          color: greenColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Compass Icon
                  SvgPicture.asset(
                    'assets/icons/opzioni.svg',
                    width: 30, // Ingrandite
                    height: 30,
                  ),
                  const SizedBox(width: 24),
                  // Bell Icon
                  SvgPicture.asset(
                    'assets/icons/notifiche.svg',
                    width: 30, // Ingrandite
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
          // AGESCI Logo on the semicircle dip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: dipRadius * 2, // 72px totali
                height: dipRadius * 2, // 72px totali
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/logo_agesci.svg',
                    width: 66, // Ingrandito
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
    
    final double bottomY = rect.height - dipRadius;
    
    path.lineTo(0, bottomY);
    
    double startX = (rect.width - dipDiameter) / 2;
    path.lineTo(startX, bottomY);
    
    // Semicerchio
    path.arcToPoint(
      Offset(startX + dipDiameter, bottomY),
      radius: const Radius.circular(dipRadius),
      clockwise: false,
    );
    
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
