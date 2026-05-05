import 'package:flutter/material.dart';

/// Barra dei filtri orizzontale per l'elenco ragazzi.
/// Permette di filtrare per squadriglia (tramite menu a tendina) e per segnalazioni mediche.
class RagazziFilters extends StatelessWidget {
  /// La squadriglia attualmente selezionata (null per "Tutte")
  final String? squadrigliaSelezionata;
  /// Stato del filtro per alert medici
  final bool alertMediciAttivo;
  /// Lista di tutte le squadriglie disponibili
  final List<String> squadriglie;
  /// Callback per il cambio della squadriglia
  final ValueChanged<String?> onSquadrigliaChanged;
  /// Callback per il toggle dell'alert medico
  final ValueChanged<bool> onAlertChanged;

  const RagazziFilters({
    super.key,
    required this.squadrigliaSelezionata,
    required this.alertMediciAttivo,
    required this.squadriglie,
    required this.onSquadrigliaChanged,
    required this.onAlertChanged,
  });

  /// Mostra il menu a tendina per la scelta della squadriglia
  void _apriDropdownSquadriglia(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    // Posizionamento del menu sotto il chip cliccato
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final scelte = [null, ...squadriglie]; // null rappresenta l'opzione "Tutte"
    
    final risultato = await showMenu<String?>(
      context: context,
      position: position,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: scelte.map((sq) => PopupMenuItem<String?>(
        value: sq,
        child: Row(
          children: [
            Icon(
              sq == null ? Icons.groups_rounded : Icons.shield_rounded,
              size: 18,
              color: sq == squadrigliaSelezionata ? const Color(0xFF1D2660) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 12),
            Text(
              sq ?? "Tutte le squadriglie",
              style: TextStyle(
                color: sq == squadrigliaSelezionata ? const Color(0xFF1D2660) : const Color(0xFF1E293B),
                fontWeight: sq == squadrigliaSelezionata ? FontWeight.w800 : FontWeight.w500,
                fontFamily: 'Lexend',
                fontSize: 14,
              ),
            ),
            if (sq == squadrigliaSelezionata) ...[
              const Spacer(),
              const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF1D2660)),
            ],
          ],
        ),
      )).toList(),
    );

    // Gestione della selezione (incluso il tocco fuori dal menu)
    if (risultato != squadrigliaSelezionata) {
      onSquadrigliaChanged(risultato);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSquadriglia = squadrigliaSelezionata != null;
    final bool nessunFiltro = !hasSquadriglia && !alertMediciAttivo;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // CHIP "TUTTI": Resetta tutti i filtri
          GestureDetector(
            onTap: () {
              onSquadrigliaChanged(null);
              onAlertChanged(false);
            },
            child: _buildChip(
              label: "Tutti",
              isSelected: nessunFiltro,
            ),
          ),
          const SizedBox(width: 8),

          // CHIP SQUADRIGLIA: Apre il dropdown
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => _apriDropdownSquadriglia(ctx),
              child: _buildChip(
                label: hasSquadriglia ? squadrigliaSelezionata! : "Squadriglia",
                isSelected: hasSquadriglia,
                hasDropdown: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // CHIP ALERT MEDICI: Filtra chi ha segnalazioni
          GestureDetector(
            onTap: () => onAlertChanged(!alertMediciAttivo),
            child: _buildChip(
              label: "Alert Medici",
              isSelected: alertMediciAttivo,
              icon: Icons.medical_services_rounded,
              isAlert: true,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper per costruire un chip coerente con lo stato del filtro
  Widget _buildChip({
    required String label,
    bool isSelected = false,
    bool hasDropdown = false,
    IconData? icon,
    bool isAlert = false,
  }) {
    // Logica cromatica dinamica
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isSelected && isAlert) {
      bgColor = const Color(0xFFE11D48); // Rosso Alert Attivo
      borderColor = const Color(0xFFE11D48);
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = const Color(0xFF1D2660); // Blu Jamb Attivo
      borderColor = const Color(0xFF1D2660);
      textColor = Colors.white;
    } else if (isAlert) {
      bgColor = const Color(0xFFFFF1F2); // Rosa Alert Inattivo
      borderColor = const Color(0xFFFECDD3);
      textColor = const Color(0xFFE11D48);
    } else {
      bgColor = Colors.white;
      borderColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF64748B);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label, 
            style: TextStyle(
              color: textColor, 
              fontSize: 13, 
              fontWeight: FontWeight.w700, 
              fontFamily: 'Lexend',
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: textColor),
          ],
        ],
      ),
    );
  }
}
