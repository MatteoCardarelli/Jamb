import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/ruolo_display.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';

/// Barra superiore personalizzata con design distintivo Jamb.
/// Presenta una forma a "tuffo" (dip) al centro che ospita il logo AGESCI,
/// icone profilo e notifiche, e nome e ruolo dell'utente collegato.
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

    final session = context.watch<SessionService>();
    final nome = session.nomeCompleto;
    final ruolo = session.activeRole == null ? '' : ruoloLabel(session.activeRole!);

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
                  color: Colors.black.withValues(alpha: 0.12),
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
                  // Avatar e info utente: toccandoli si apre il menu del profilo.
                  // Il totem non è nel database: sotto il nome si mostra il ruolo.
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _apriMenuProfilo(context, nome, ruolo),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/profilo.svg',
                            width: 36,
                            height: 36,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nome,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: greenColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                                Text(
                                  ruolo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: greenColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 9,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Spazio libero sotto il logo centrale.
                  const SizedBox(width: 72),
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

  /// Menu del profilo: chi è collegato e il tasto per uscire.
  void _apriMenuProfilo(BuildContext context, String nome, String ruolo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D2660),
                  fontFamily: 'Lexend',
                ),
              ),
              if (ruolo.isNotEmpty)
                Text(
                  ruolo,
                  style: const TextStyle(color: Color(0xFF64748B), fontFamily: 'Lexend'),
                ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFB91C1C)),
                title: const Text(
                  'Esci',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lexend',
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  // L'app si ricrea per il nuovo stato della sessione e torna al login.
                  eseguiConFeedback(context, context.read<SessionService>().logout);
                },
              ),
            ],
          ),
        ),
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
