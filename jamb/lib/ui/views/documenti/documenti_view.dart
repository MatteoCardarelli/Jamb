import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_category_card.dart';
import 'package:jamb/ui/core/widgets/jamb_expandable_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/views/documenti/widgets/recent_document_card.dart';
import 'package:jamb/ui/views/amministrazione/amministrazione_view.dart';
import 'package:jamb/core/providers/amministrazione_provider.dart';
import 'package:jamb/ui/views/explorer/explorer_view.dart';
import 'package:jamb/ui/views/contabilita/contabilita_view.dart';

/// Hub centrale per la gestione dei documenti e delle sezioni amministrative.
/// Fornisce accesso rapido ai Drive condivisi, alla Contabilità, all'Amministrazione
/// e visualizza un elenco dei file modificati di recente.
class DocumentiView extends StatefulWidget {
  const DocumentiView({super.key});

  @override
  State<DocumentiView> createState() => _DocumentiViewState();
}

class _DocumentiViewState extends State<DocumentiView> {
  final TextEditingController _searchCtrl = TextEditingController();
  
  // --- CONFIGURAZIONE CATEGORIE ---
  // In una fase successiva, questi dati potrebbero provenire da un Provider
  final List<Map<String, dynamic>> _allCategories = [
    {"titolo": "Drive di Branca", "sottotitolo": "File condivisi", "icona": Icons.folder_shared_rounded},
    {"titolo": "Drive di Co.Ca.", "sottotitolo": "File condivisi", "icona": Icons.folder_special_rounded},
    {"titolo": "Amministrazione", "sottotitolo": "Censimenti e dati", "icona": Icons.admin_panel_settings_rounded},
    {"titolo": "Modulistica Uscite", "sottotitolo": "Template e moduli", "icona": Icons.assignment_rounded},
    {"titolo": "Contabilità", "sottotitolo": "Spese e rimborsi", "icona": Icons.payments_rounded},
    {"titolo": "Metodo e Statuto", "sottotitolo": "Documenti ufficiali", "icona": Icons.menu_book_rounded},
  ];
  
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _allCategories;
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Gestisce il filtraggio delle categorie in base alla ricerca testuale
  void _onSearchChanged() {
    setState(() {
      _filteredCategories = _allCategories
          .where((c) => c['titolo'].toLowerCase().contains(_searchCtrl.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recupero dati per la barra di progresso del modulo Amministrazione
    final adminProvider = Provider.of<AmministrazioneProvider>(context);
    final int totaliRagazzi = adminProvider.totali;
    final int ragazziOk = adminProvider.ragazziTuttoOk;

    // Paracadute: ripristina la lista se la ricerca viene svuotata
    if (_filteredCategories.isEmpty && _searchCtrl.text.isEmpty) {
      _filteredCategories = _allCategories;
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: EmptyBackgroundScreen(
        currentIndex: 2, // Icona documenti attiva
        floatingActionButton: JambExpandableFab(
          onCreateFolder: () => JambDialogs.showCreateFolderDialog(context),
          onUploadDocument: () => JambDialogs.showUploadDocumentDialog(context),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARRA DI RICERCA
              JambSearchBar(
                controller: _searchCtrl,
                hintText: "Cerca documenti...",
              ),
              const SizedBox(height: 35),

              // TITOLO SEZIONE: CATEGORIE
              const Text(
                "Categorie",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 16),

              // GRIGLIA DELLE CATEGORIE
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  final cat = _filteredCategories[index];
                  
                  // Definizione dinamica della rotta di destinazione
                  VoidCallback? onTap;
                  if (cat['titolo'] == "Drive di Branca") {
                    onTap = () => _navigateTo(context, const ExplorerView(
                      titolo: "Drive di Branca",
                      cartelle: ["2025-2026", "2024-2025", "2023-2024", "Archivio"],
                    ));
                  } else if (cat['titolo'] == "Drive di Co.Ca.") {
                    onTap = () => _navigateTo(context, const ExplorerView(
                      titolo: "Drive di Co.Ca.",
                      cartelle: ["Programmazione", "Verbali", "Progetto Educativo"],
                    ));
                  } else if (cat['titolo'] == "Amministrazione") {
                    onTap = () => _navigateTo(context, const AmministrazioneView());
                  } else if (cat['titolo'] == "Contabilità") {
                    onTap = () => _navigateTo(context, const ContabilitaView());
                  }

                  // Calcolo del progresso per il badge amministrativo
                  final bool isAdmin = cat['titolo'] == "Amministrazione";
                  final double? progresso = isAdmin ? (totaliRagazzi > 0 ? ragazziOk / totaliRagazzi : 0) : null;
                  final String? progressoTesto = isAdmin ? "$ragazziOk/$totaliRagazzi" : null;

                  return JambCategoryCard(
                    titolo: cat['titolo'],
                    sottotitolo: cat['sottotitolo'],
                    icona: cat['icona'],
                    progresso: progresso,
                    progressoTesto: progressoTesto,
                    onTap: onTap,
                  );
                },
              ),
              const SizedBox(height: 40),

              // SEZIONE: DOCUMENTI RECENTI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Documenti Recenti",
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigazione alla lista completa dei documenti recenti
                    },
                    child: const Text(
                      "Vedi tutti",
                      style: TextStyle(
                        color: Color(0xFF1D2660),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // LISTA DOCUMENTI RECENTI (Mock)
              const RecentDocumentCard(
                titolo: "Regolamento_Metodologico_20",
                info: "Modificato ieri • 2.4 MB",
                tipo: FileType.pdf,
              ),
              const RecentDocumentCard(
                titolo: "Modulo_Autorizzazione_Uscita",
                info: "Modificato 3h fa • 120 KB",
                tipo: FileType.doc,
              ),
              const RecentDocumentCard(
                titolo: "Scansione_Scheda_Medica_Ro",
                info: "Caricato oggi • 1.1 MB",
                tipo: FileType.image,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper per la navigazione con transizione immediata
  void _navigateTo(BuildContext context, Widget view) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => view,
      transitionDuration: Duration.zero,
    ));
  }
}
