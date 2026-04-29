import 'package:flutter/material.dart';

class RagazziFilters extends StatelessWidget {
  final String? squadrigliaSelezionata;
  final bool alertMediciAttivo;
  final List<String> squadriglie;
  final ValueChanged<String?> onSquadrigliaChanged;
  final ValueChanged<bool> onAlertChanged;

  const RagazziFilters({
    super.key,
    required this.squadrigliaSelezionata,
    required this.alertMediciAttivo,
    required this.squadriglie,
    required this.onSquadrigliaChanged,
    required this.onAlertChanged,
  });

  void _apriDropdownSquadriglia(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final scelte = [null, ...squadriglie]; // null = "Tutte"
    final risultato = await showMenu<String?>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: scelte.map((sq) => PopupMenuItem<String?>(
        value: sq,
        child: Row(
          children: [
            Icon(
              sq == null ? Icons.group_outlined : Icons.shield_outlined,
              size: 16,
              color: sq == squadrigliaSelezionata ? const Color(0xFF00005C) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              sq ?? "Tutte le squadriglie",
              style: TextStyle(
                color: sq == squadrigliaSelezionata ? const Color(0xFF00005C) : const Color(0xFF1E293B),
                fontWeight: sq == squadrigliaSelezionata ? FontWeight.w700 : FontWeight.w400,
                fontFamily: 'Lexend',
                fontSize: 14,
              ),
            ),
            if (sq == squadrigliaSelezionata) ...[
              const Spacer(),
              const Icon(Icons.check, size: 16, color: Color(0xFF00005C)),
            ],
          ],
        ),
      )).toList(),
    );

    if (risultato != null || risultato == null) {
      onSquadrigliaChanged(risultato);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSquadriglia = squadrigliaSelezionata != null;
    final bool nessunFiltro = !hasSquadriglia && !alertMediciAttivo;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Chip "Tutti"
          GestureDetector(
            onTap: () {
              onSquadrigliaChanged(null);
              onAlertChanged(false);
            },
            child: _chip(
              label: "Tutti",
              isSelected: nessunFiltro,
            ),
          ),
          const SizedBox(width: 8),

          // Chip Squadriglia con dropdown
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => _apriDropdownSquadriglia(ctx),
              child: _chip(
                label: hasSquadriglia ? squadrigliaSelezionata! : "Squadriglia",
                isSelected: hasSquadriglia,
                hasDropdown: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Chip Alert Medici
          GestureDetector(
            onTap: () => onAlertChanged(!alertMediciAttivo),
            child: _chip(
              label: "Alert Medici",
              isSelected: alertMediciAttivo,
              icon: Icons.medical_services_outlined,
              isAlert: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    bool isSelected = false,
    bool hasDropdown = false,
    IconData? icon,
    bool isAlert = false,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isSelected && isAlert) {
      bgColor = const Color(0xFFE11D48);
      borderColor = const Color(0xFFE11D48);
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = const Color(0xFF00005C);
      borderColor = const Color(0xFF00005C);
      textColor = Colors.white;
    } else if (isAlert) {
      bgColor = const Color(0xFFFFF1F2);
      borderColor = const Color(0xFFFECDD3);
      textColor = const Color(0xFFE11D48);
    } else {
      bgColor = Colors.white;
      borderColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Lexend')),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: textColor),
          ],
        ],
      ),
    );
  }
}
