import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_chip_filtro.dart';

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
          JambChipFiltro(
            etichetta: "Tutti",
            selezionato: nessunFiltro,
            onTap: () {
              onSquadrigliaChanged(null);
              onAlertChanged(false);
            },
          ),
          const SizedBox(width: 8),

          // CHIP SQUADRIGLIA: Apre il dropdown
          Builder(
            builder: (ctx) => JambChipFiltro(
              etichetta: hasSquadriglia ? squadrigliaSelezionata! : "Squadriglia",
              selezionato: hasSquadriglia,
              menu: true,
              onTap: () => _apriDropdownSquadriglia(ctx),
            ),
          ),
          const SizedBox(width: 8),

          // CHIP ALERT MEDICI: Filtra chi ha segnalazioni
          JambChipFiltro(
            etichetta: "Alert Medici",
            selezionato: alertMediciAttivo,
            icona: Icons.medical_services_rounded,
            alert: true,
            onTap: () => onAlertChanged(!alertMediciAttivo),
          ),
        ],
      ),
    );
  }
}
