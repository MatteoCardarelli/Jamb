import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_category_card.dart';
import 'package:jamb/ui/core/widgets/jamb_expandable_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/explorer/view_model/explorer_view_model.dart';

/// Schermata per l'esplorazione gerarchica dei documenti e delle cartelle.
/// Supporta la navigazione ricorsiva, la ricerca e la gestione del percorso (Breadcrumbs).
class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExplorerViewModel>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: EmptyBackgroundScreen(
        currentIndex: 2, // Icona documenti selezionata
        floatingActionButton: JambExpandableFab(
          onCreateFolder: () => JambDialogs.showCreateFolderDialog(context, initialPath: viewModel.fullPath.join(" > ")),
          onUploadDocument: () => JambDialogs.showUploadDocumentDialog(context, initialPath: viewModel.fullPath.join(" > ")),
        ),
        child: SingleChildScrollView(
          // Padding top di 170 per stare sotto la TopBar
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARRA DI RICERCA
              JambSearchBar(
                controller: viewModel.searchController,
                hintText: "Cerca file o cartelle...",
              ),
              const SizedBox(height: 24),

              // AREA BREADCRUMBS: Navigazione orizzontale nel percorso
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildBreadcrumbItem(
                      label: "Documenti", 
                      icon: Icons.folder_open_rounded,
                      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    ),
                    ...List.generate(viewModel.fullPath.length, (index) {
                      final isLast = index == viewModel.fullPath.length - 1;
                      return Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF64748B)),
                          ),
                          _buildBreadcrumbItem(
                            label: viewModel.fullPath[index],
                            icon: isLast ? Icons.folder_rounded : Icons.folder_outlined,
                            isLast: isLast,
                            onTap: isLast ? null : () {
                              // Navigazione a ritroso: torna indietro di N posizioni nella stack delle rotte
                              int steps = viewModel.fullPath.length - 1 - index;
                              for(int i=0; i<steps; i++) Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // GRIGLIA CARTELLE
              if (viewModel.filteredCartelle.isEmpty)
                _buildEmptyState()
              else
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
                  itemCount: viewModel.filteredCartelle.length,
                  itemBuilder: (context, index) {
                    final folderName = viewModel.filteredCartelle[index];
                    return JambCategoryCard(
                      titolo: folderName,
                      sottotitolo: "Cartella",
                      icona: Icons.folder_rounded,
                      onTap: () {
                        // Navigazione ricorsiva verso una nuova ExplorerScreen
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider(
                            create: (_) => ExplorerViewModel(
                              titolo: folderName,
                              cartelle: const [], // Mock di cartella vuota
                              percorsoPrecedente: viewModel.fullPath,
                            ),
                            child: const ExplorerScreen(),
                          ),
                          transitionDuration: Duration.zero,
                        ));
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Stato visualizzato quando non ci sono cartelle o la ricerca fallisce
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Text(
          "Nessun risultato trovato",
          style: TextStyle(
            color: Color(0xFF64748B), 
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Costruisce un singolo elemento del percorso (Breadcrumb)
  Widget _buildBreadcrumbItem({
    required String label, 
    required IconData icon, 
    bool isLast = false, 
    VoidCallback? onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon, 
            size: 18, 
            color: isLast ? const Color(0xFF25315B) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isLast ? const Color(0xFF25315B) : const Color(0xFF64748B),
              fontSize: 14,
              fontWeight: isLast ? FontWeight.w900 : FontWeight.w700,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}
