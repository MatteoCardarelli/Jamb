import 'package:flutter/material.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/dettaglio_ragazzo_view.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/specialita_widget.dart';

/// Card riassuntiva per un singolo scout nella lista ragazzi.
/// Mostra informazioni anagrafiche, ruolo, tappa del sentiero e stato della specialità in corso.
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
        // Navigazione verso il dettaglio completo del ragazzo
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
            // --- HEADER: NOME, SQUADRIGLIA E RUOLO ---
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
                              // Badge per segnalazioni mediche
                              if (hasAlert) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.medical_services_rounded, size: 16, color: Color(0xFFE11D48)),
                              ],
                            ],
                          ),
                          const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Tag Squadriglia
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5), // Arancione pallido
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
                          // Etichetta Ruolo
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
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),
            
            // --- FOOTER: TAPPA SENTIERO E PROGRESSO SPECIALITÀ ---
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
                // Sezione dinamica per le specialità
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

  /// Calcola e visualizza le info della specialità in corso
  Widget _buildSpecialitaInfo() {
    if (specialita.isEmpty) {
      return _buildInfoColumn("SPECIALITÀ", 0.0, "Nessuna specialità");
    }

    // Verifica se tutte le specialità in lista sono già state raggiunte
    final tutteCompletate = specialita.every((s) => s.raggiunta);
    if (tutteCompletate) {
      return _buildInfoColumn("SPECIALITÀ", 1.0, "Specialità ottenuta", color: const Color(0xFF16A34A));
    }

    // Prende la prima specialità non ancora completata come "in corso"
    final inCorso = specialita.firstWhere((s) => !s.raggiunta);
    final completate = inCorso.prove.where((p) => p.completata).length;
    final totale = inCorso.prove.length;
    
    return _buildInfoColumn(
      inCorso.nome.toUpperCase(),
      totale > 0 ? completate / totale : 0.0,
      "$completate/$totale prove",
    );
  }

  /// Helper per costruire una colonna informativa con barra di progresso
  Widget _buildInfoColumn(String label, double progress, String footerText, {Color color = const Color(0xFF1E293B)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Lexend'),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          footerText, 
          style: TextStyle(
            color: progress >= 1.0 ? color : const Color(0xFF475569), 
            fontSize: 11, 
            fontWeight: FontWeight.w500, 
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
