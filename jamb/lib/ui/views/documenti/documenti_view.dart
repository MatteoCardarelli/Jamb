import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/views/documenti/widgets/categoria_card.dart';
import 'package:jamb/ui/views/documenti/widgets/recent_document_card.dart';
import 'package:jamb/ui/views/documenti/amministrazione_view.dart';
import 'package:jamb/ui/views/documenti/widgets/status_row_card.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/providers/amministrazione_provider.dart';
import 'package:jamb/ui/core/widgets/jamb_expandable_fab.dart';

class DocumentiView extends StatefulWidget {
  const DocumentiView({super.key});

  @override
  State<DocumentiView> createState() => _DocumentiViewState();
}

class _DocumentiViewState extends State<DocumentiView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AmministrazioneProvider>(context);
    final int totaliRagazzi = adminProvider.totali;
    final int ragazziOk = adminProvider.ragazziTuttoOk;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 2,
        floatingActionButton: const JambExpandableFab(),
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
              GridView.count(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  const CategoriaCard(
                    titolo: "Drive di Branca",
                    sottotitolo: "File condivisi",
                    icona: Icons.folder_shared_rounded,
                  ),
                  CategoriaCard(
                    titolo: "Drive di Co.Ca.",
                    sottotitolo: "File condivisi",
                    icona: Icons.folder_special_rounded,
                  ),
                  CategoriaCard(
                    titolo: "Amministrazione",
                    sottotitolo: "",
                    icona: Icons.admin_panel_settings_rounded,
                    progresso: totaliRagazzi > 0 ? ragazziOk / totaliRagazzi : 0,
                    progressoTesto: "$ragazziOk/$totaliRagazzi",
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const AmministrazioneView(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  CategoriaCard(
                    titolo: "Modulistica Uscite",
                    sottotitolo: "Template e moduli",
                    icona: Icons.assignment_rounded,
                  ),
                  CategoriaCard(
                    titolo: "Contabilità",
                    sottotitolo: "Spese e rimborsi",
                    icona: Icons.payments_rounded,
                  ),
                  CategoriaCard(
                    titolo: "Metodo e Statuto",
                    sottotitolo: "Documenti ufficiali",
                    icona: Icons.menu_book_rounded,
                  ),
                ],
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
