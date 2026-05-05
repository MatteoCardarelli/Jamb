import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_category_card.dart';
import 'package:jamb/ui/views/documenti/widgets/recent_document_card.dart';
import 'package:jamb/ui/views/documenti/amministrazione_view.dart';
import 'package:jamb/ui/views/documenti/widgets/status_row_card.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/providers/amministrazione_provider.dart';
import 'package:jamb/ui/core/widgets/jamb_expandable_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';

import 'package:jamb/ui/views/explorer/explorer_view.dart';
import 'package:jamb/ui/views/contabilita/contabilita_view.dart';


class DocumentiView extends StatefulWidget {
  const DocumentiView({super.key});

  @override
  State<DocumentiView> createState() => _DocumentiViewState();
}

class _DocumentiViewState extends State<DocumentiView> {
  final TextEditingController _searchCtrl = TextEditingController();
  
  // Dati per la ricerca
  final List<Map<String, dynamic>> _allCategories = [
    {"titolo": "Drive di Branca", "sottotitolo": "File condivisi", "icona": Icons.folder_shared_rounded},
    {"titolo": "Drive di Co.Ca.", "sottotitolo": "File condivisi", "icona": Icons.folder_special_rounded},
    {"titolo": "Amministrazione", "sottotitolo": "", "icona": Icons.admin_panel_settings_rounded, "isSpecial": true},
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

  void _onSearchChanged() {
    setState(() {
      _filteredCategories = _allCategories
          .where((c) => c['titolo'].toLowerCase().contains(_searchCtrl.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AmministrazioneProvider>(context);
    final int totaliRagazzi = adminProvider.totali;
    final int ragazziOk = adminProvider.ragazziTuttoOk;

    // Paracadute: se la lista è vuota e non stiamo cercando nulla, ricarica tutto
    if (_filteredCategories.isEmpty && _searchCtrl.text.isEmpty) {
      _filteredCategories = _allCategories;
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false, // BLOCCA EFFETTO FISARMONICA
      body: EmptyBackgroundScreen(
        currentIndex: 2,
        floatingActionButton: JambExpandableFab(
          onCreateFolder: () => JambDialogs.showCreateFolderDialog(context),
          onUploadDocument: () => JambDialogs.showUploadDocumentDialog(context),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra di ricerca superiore
              JambSearchBar(
                controller: _searchCtrl,
                hintText: "Cerca documenti...",
              ),
              const SizedBox(height: 35),

              // Titolo Sezione
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
              const SizedBox(height: 4),

              // Griglia Categorie
              // Griglia Categorie FILTRATA
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  final cat = _filteredCategories[index];
                  
                  // Logica speciale per il navigatore
                  VoidCallback? onTap;
                  if (cat['titolo'] == "Drive di Branca") {
                    onTap = () => Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ExplorerView(
                        titolo: "Drive di Branca",
                        cartelle: ["2025-2026", "2024-2025", "2023-2024", "2022-2023", "2021-2022", "2020-2021", "2019-2020"],
                      ),
                      transitionDuration: Duration.zero,
                    ));
                  } else if (cat['titolo'] == "Drive di Co.Ca.") {
                    onTap = () => Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ExplorerView(
                        titolo: "Drive di Co.Ca.",
                        cartelle: ["Programmazione", "Verbali", "Progetto Educativo", "Archivio Storico"],
                      ),
                      transitionDuration: Duration.zero,
                    ));
                  } else if (cat['titolo'] == "Amministrazione") {
                    onTap = () => Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const AmministrazioneView(),
                      transitionDuration: Duration.zero,
                    ));
                  } else if (cat['titolo'] == "Contabilità") {
                    onTap = () => Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ContabilitaView(),
                      transitionDuration: Duration.zero,
                    ));
                  }

                  return JambCategoryCard(
                    titolo: cat['titolo'],
                    sottotitolo: cat['sottotitolo'],
                    icona: cat['icona'],
                    progresso: cat['titolo'] == "Amministrazione" ? (totaliRagazzi > 0 ? ragazziOk / totaliRagazzi : 0) : null,
                    progressoTesto: cat['titolo'] == "Amministrazione" ? "$ragazziOk/$totaliRagazzi" : null,
                    onTap: onTap,
                  );
                },
              ),
              const SizedBox(height: 32),

              // Intestazione Documenti Recenti
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
                    onPressed: () {},
                    child: const Text(
                      "Vedi tutti",
                      style: TextStyle(
                        color: Color(0xFF25315B),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista Documenti Recenti
              const RecentDocumentCard(
                titolo: "Regolamento_Metodologico_20",
                info: "Modificato ieri • 2.4 MB",
                tipo: FileType.pdf,
              ),
              const RecentDocumentCard(
                titolo: "Modulo_Autorizzazione_Uscita..",
                info: "Modificato 3h fa • 120 KB",
                tipo: FileType.doc,
              ),
              const RecentDocumentCard(
                titolo: "Scansione_Scheda_Medica_Ro..",
                info: "Caricato oggi • 1.1 MB",
                tipo: FileType.image,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
