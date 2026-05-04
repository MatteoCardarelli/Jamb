import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/views/documenti/widgets/status_documento_card.dart';
import 'package:jamb/ui/views/documenti/widgets/status_row_card.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/providers/amministrazione_provider.dart';

class AmministrazioneView extends StatefulWidget {
  const AmministrazioneView({super.key});

  @override
  State<AmministrazioneView> createState() => _AmministrazioneViewState();
}

class _AmministrazioneViewState extends State<AmministrazioneView> {
  String _selectedFilter = "Tutti";

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AmministrazioneProvider>(context);

    // Gestione filtri sulla lista globale del provider
    List<RagazzoDocumenti> filteredData = adminProvider.ragazzi;
    if (_selectedFilter == "Incompleti") {
      filteredData = adminProvider.ragazzi.where((row) => 
        row.censimento == DocumentStatus.none || 
        row.censimento == DocumentStatus.missing ||
        row.privacy == DocumentStatus.none ||
        row.privacy == DocumentStatus.missing ||
        row.medica == DocumentStatus.none ||
        row.medica == DocumentStatus.missing
      ).toList();
    } else if (_selectedFilter == "In Scadenza") {
      filteredData = adminProvider.ragazzi.where((row) => 
        row.censimento == DocumentStatus.expiring || 
        row.privacy == DocumentStatus.expiring ||
        row.medica == DocumentStatus.expiring
      ).toList();
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 2,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intestazione con tasto back
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF25315B)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Amministrazione",
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Card di stato dinamiche dal provider
              StatusDocumentoCard(
                titolo: "Censimenti",
                icona: Icons.assignment_ind_outlined,
                attuali: adminProvider.censValid,
                totali: adminProvider.totali,
              ),
              StatusDocumentoCard(
                titolo: "Privacy",
                icona: Icons.verified_user_outlined,
                attuali: adminProvider.privValid,
                totali: adminProvider.totali,
              ),
              StatusDocumentoCard(
                titolo: "Schede Mediche",
                icona: Icons.medical_services_outlined,
                attuali: adminProvider.medValid,
                totali: adminProvider.totali,
              ),

              const SizedBox(height: 32),

              // Filtri
              Row(
                children: [
                  _buildFilterChip("Tutti"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Incompleti"),
                  const SizedBox(width: 8),
                  _buildFilterChip("In Scadenza"),
                ],
              ),
              const SizedBox(height: 12),

              // Legenda
              Row(
                children: [
                  _buildLegendItem(const Color(0xFF22C55E), "Valido"),
                  const SizedBox(width: 16),
                  _buildLegendItem(const Color(0xFFF59E0B), "In Scadenza"),
                  const SizedBox(width: 16),
                  _buildLegendItem(const Color(0xFFEF4444), "Scaduto/Mancante"),
                ],
              ),

              const SizedBox(height: 24),

              // Header Tabella
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
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Lexend',
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

              // Lista Ragazzi dal Provider
              ...filteredData.map((ragazzo) => StatusRowCard(
                initials: ragazzo.initials,
                nome: ragazzo.nome,
                censimento: ragazzo.censimento,
                privacy: ragazzo.privacy,
                medica: ragazzo.medica,
                onCensimentoTap: () => adminProvider.cycleStatus(ragazzo.id, 'censimento'),
                onPrivacyTap: () => adminProvider.cycleStatus(ragazzo.id, 'privacy'),
                onMedicaTap: () => adminProvider.cycleStatus(ragazzo.id, 'medica'),
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
  );

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
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
