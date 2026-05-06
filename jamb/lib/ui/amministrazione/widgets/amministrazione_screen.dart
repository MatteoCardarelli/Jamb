import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';
import 'package:jamb/ui/amministrazione/widgets/status_documento_card.dart';
import 'package:jamb/ui/amministrazione/widgets/status_row_card.dart';
import 'package:jamb/ui/amministrazione/view_model/amministrazione_view_model.dart';
import 'package:jamb/domain/entities/scout.dart';

/// Vista dedicata alla gestione amministrativa dei ragazzi (Censimenti, Privacy, Schede Mediche).
/// Permette di monitorare lo stato dei documenti globali e di ogni singolo scout attraverso
/// filtri dinamici e una tabella riassuntiva interattiva.
class AmministrazioneScreen extends StatefulWidget {
  const AmministrazioneScreen({super.key});

  @override
  State<AmministrazioneScreen> createState() => _AmministrazioneScreenState();
}

class _AmministrazioneScreenState extends State<AmministrazioneScreen> {
  // Filtro attualmente attivo nella tabella
  String _selectedFilter = "Tutti";

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AmministrazioneViewModel>(context);

    // LOGICA DI FILTRAGGIO DEI DATI
    List<Scout> filteredData = adminViewModel.ragazzi;
    if (_selectedFilter == "Incompleti") {
      filteredData = adminViewModel.ragazzi.where((row) => 
        row.statoCensimento == DocumentoStatus.nessuno || 
        row.statoCensimento == DocumentoStatus.scaduto ||
        row.statoPrivacy == DocumentoStatus.nessuno ||
        row.statoPrivacy == DocumentoStatus.scaduto ||
        row.statoMedica == DocumentoStatus.nessuno ||
        row.statoMedica == DocumentoStatus.scaduto
      ).toList();
    } else if (_selectedFilter == "In Scadenza") {
      filteredData = adminViewModel.ragazzi.where((row) => 
        row.statoCensimento == DocumentoStatus.inScadenza || 
        row.statoPrivacy == DocumentoStatus.inScadenza ||
        row.statoMedica == DocumentoStatus.inScadenza
      ).toList();
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 2,
        child: adminViewModel.isLoading 
          ? const Center(child: CircularProgressIndicator()) // Mostra caricamento
          : SingleChildScrollView(
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- INTESTAZIONE ---
                  Row(
                    children: [
                      const BackActionButton(),
                      const SizedBox(width: 16),
                      const Text(
                        "Amministrazione",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- STATISTICHE GLOBALI ---
                  StatusDocumentoCard(
                    titolo: "Censimenti",
                    icona: Icons.assignment_ind_rounded,
                    attuali: adminViewModel.censValid,
                    totali: adminViewModel.totali,
                  ),
                  const SizedBox(height: 12),
                  StatusDocumentoCard(
                    titolo: "Privacy",
                    icona: Icons.verified_user_rounded,
                    attuali: adminViewModel.privValid,
                    totali: adminViewModel.totali,
                  ),
                  const SizedBox(height: 12),
                  StatusDocumentoCard(
                    titolo: "Schede Mediche",
                    icona: Icons.medical_services_rounded,
                    attuali: adminViewModel.medValid,
                    totali: adminViewModel.totali,
                  ),

                  const SizedBox(height: 32),

                  // --- FILTRI TABELLA ---
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip("Tutti"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Incompleti"),
                        const SizedBox(width: 8),
                        _buildFilterChip("In Scadenza"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- LEGENDA ---
                  Row(
                    children: [
                      _buildLegendItem(const Color(0xFF22C55E), "Valido"),
                      const SizedBox(width: 16),
                      _buildLegendItem(const Color(0xFFF59E0B), "In Scadenza"),
                      const SizedBox(width: 16),
                      _buildLegendItem(const Color(0xFFEF4444), "Mancante"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- HEADER TABELLA ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: const [
                        SizedBox(width: 48),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "NOMINATIVO",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Lexend',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(child: Center(child: Text("CENS.", style: _headerStyle))),
                        Expanded(child: Center(child: Text("PRIV.", style: _headerStyle))),
                        Expanded(child: Center(child: Text("MED.", style: _headerStyle))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- LISTA RAGAZZI ---
                  if (filteredData.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          "Nessun dato corrispondente ai filtri",
                          style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Lexend'),
                        ),
                      ),
                    )
                  else
                    ...filteredData.map((ragazzo) => StatusRowCard(
                      ragazzo: ragazzo,
                      onCensimentoTap: () => adminViewModel.updateCensimento(ragazzo.id),
                      onPrivacyTap: () => adminViewModel.updatePrivacy(ragazzo.id),
                      onMedicaTap: () => adminViewModel.updateMedica(ragazzo.id),
                    )),
                ],
              ),
            ),
      ),
    );
  }

  static const _headerStyle = TextStyle(
    color: Color(0xFF94A3B8),
    fontSize: 10,
    fontWeight: FontWeight.w800,
    fontFamily: 'Lexend',
    letterSpacing: 0.5,
  );

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D2660) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D2660) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
