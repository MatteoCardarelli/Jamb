import 'package:flutter/material.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/dettaglio_ragazzo_view.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/specialita_widget.dart';

class RagazzoCard extends StatelessWidget {
  final String nome;
  final String squadriglia;
  final String ruolo;
  final String tappa;
  final bool hasAlert;
  final List<Specialita> specialita;

  const RagazzoCard({
    super.key,
    required this.nome,
    required this.squadriglia,
    required this.ruolo,
    required this.tappa,
    required this.hasAlert,
    required this.specialita,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DettaglioRagazzoView(
              nome: nome,
              squadriglia: squadriglia,
              ruolo: ruolo,
              hasAlert: hasAlert,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                nome,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  fontFamily: 'Lexend',
                                ),
                              ),
                              if (hasAlert) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.medical_services, size: 16, color: Color(0xFFE11D48)),
                              ],
                            ],
                          ),
                          const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              squadriglia,
                              style: const TextStyle(
                                color: Color(0xFFEA580C),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ruolo,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TAPPA SENTIERO",
                        style: TextStyle(
                          color: Color(0xFF94A3B8), 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tappa,
                        style: const TextStyle(
                          color: Color(0xFF475569), 
                          fontSize: 13, 
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildSpecialitaInfo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Calcola e visualizza le info della specialità in corso
  Widget _buildSpecialitaInfo() {
    if (specialita.isEmpty) {
      return _specialitaColonna("SPECIALITÀ", 0.0, "Nessuna specialità");
    }

    // Tutte le specialità completate?
    final tutteCompletate = specialita.every((s) => s.raggiunta);
    if (tutteCompletate) {
      return _specialitaColonna("SPECIALITÀ", 1.0, "Specialità ottenuta", colore: const Color(0xFF16A34A));
    }

    // Prima specialità in corso (non ancora raggiunta)
    final inCorso = specialita.firstWhere((s) => !s.raggiunta);
    final completate = inCorso.prove.where((p) => p.completata).length;
    final totale = inCorso.prove.length;
    return _specialitaColonna(
      inCorso.nome.toUpperCase(),
      totale > 0 ? completate / totale : 0.0,
      "$completate/$totale prove",
    );
  }

  Widget _specialitaColonna(String label, double valore, String testo, {Color colore = const Color(0xFF1E293B)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: valore,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(colore),
          ),
        ),
        const SizedBox(height: 4),
        Text(testo, style: TextStyle(color: valore >= 1.0 ? colore : const Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Lexend')),
      ],
    );
  }
}
