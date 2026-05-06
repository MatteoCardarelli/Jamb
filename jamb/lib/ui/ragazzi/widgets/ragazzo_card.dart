import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/scout.dart';
import 'package:jamb/domain/entities/progresso.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/ui/ragazzi/view_model/ragazzi_view_model.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/dettaglio_ragazzo_screen.dart';
import 'package:jamb/ui/dettaglio_ragazzo/view_model/dettaglio_ragazzo_view_model.dart';

/// Card riassuntiva per un singolo scout nella lista ragazzi.
/// Riceve direttamente l'entità di dominio [Scout] (Shared Model).
class RagazzoCard extends StatelessWidget {
  final Scout scout;

  const RagazzoCard({
    super.key,
    required this.scout,
  });

  @override
  Widget build(BuildContext context) {
    // Mostra l'alert solo se ci sono allergie
    final bool hasAlert = scout.allergie != null && scout.allergie!.trim().isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, __, ___) => ChangeNotifierProvider(
              create: (_) => DettaglioRagazzoViewModel(
                scout: scout,
                repository: context.read<IScoutRepository>(),
              ),
              child: DettaglioRagazzoScreen(scout: scout),
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ).then((_) {
          // Quando torniamo indietro, rinfreschiamo la lista principale
          // per mostrare i dati aggiornati
          context.read<RagazziViewModel>().refresh();
        });
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
                                scout.nome,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  fontFamily: 'Lexend',
                                ),
                              ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              scout.squadriglia.toUpperCase(),
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
                            scout.ruolo,
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
                        scout.progresso.tappaAttuale.tipo.name.toUpperCase(),
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

  Widget _buildSpecialitaInfo() {
    final specialita = scout.progresso.specialita;
    if (specialita.isEmpty) {
      return _buildInfoColumn("SPECIALITÀ", 0.0, "Nessuna specialità");
    }

    final inCorso = specialita.firstWhere((s) => !s.isPosseduta, orElse: () => specialita.first);
    
    if (inCorso.isPosseduta) {
       return _buildInfoColumn("SPECIALITÀ", 1.0, "Ottenuta", color: const Color(0xFF16A34A));
    }

    final completate = inCorso.prove.where((p) => p.isCompletato).length;
    final totale = 3; // Standard scout
    
    return _buildInfoColumn(
      inCorso.nome.name.toUpperCase(),
      completate / totale,
      "$completate/$totale prove",
    );
  }

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
