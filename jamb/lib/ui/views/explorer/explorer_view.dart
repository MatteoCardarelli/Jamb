import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_category_card.dart';
import 'package:jamb/ui/core/widgets/jamb_expandable_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';

class ExplorerView extends StatefulWidget {
  final String titolo;
  final List<String> cartelle;
  final List<String> percorso; // Nuovo: tiene traccia del cammino fatto

  const ExplorerView({
    super.key,
    required this.titolo,
    required this.cartelle,
    this.percorso = const [],
  });

  @override
  State<ExplorerView> createState() => _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<String> _filteredCartelle = [];
  late List<String> _fullPath;

  @override
  void initState() {
    super.initState();
    _filteredCartelle = widget.cartelle;
    _searchCtrl.addListener(_onSearchChanged);
    _fullPath = [...widget.percorso, widget.titolo];
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredCartelle = widget.cartelle
          .where((c) => c.toLowerCase().contains(_searchCtrl.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: EmptyBackgroundScreen(
        currentIndex: 2,
        floatingActionButton: JambExpandableFab(
          onCreateFolder: () => JambDialogs.showCreateFolderDialog(context, initialPath: _fullPath.join(" > ")),
          onUploadDocument: () => JambDialogs.showUploadDocumentDialog(context, initialPath: _fullPath.join(" > ")),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JambSearchBar(
                controller: _searchCtrl,
                hintText: "Cerca file o cartelle...",
              ),
              const SizedBox(height: 24),

              // Breadcrumbs Dinamici e Cliccabili
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildBreadcrumbItem(
                      label: "Documenti", 
                      icon: Icons.folder_open_rounded,
                      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    ),
                    ...List.generate(_fullPath.length, (index) {
                      final isLast = index == _fullPath.length - 1;
                      return Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF64748B)),
                          ),
                          _buildBreadcrumbItem(
                            label: _fullPath[index],
                            icon: isLast ? Icons.folder_rounded : Icons.folder_outlined,
                            isLast: isLast,
                            onTap: isLast ? null : () {
                              // Torna indietro di N posizioni nella stack
                              int steps = _fullPath.length - 1 - index;
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

              if (_filteredCartelle.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Text(
                      "Nessun risultato trovato",
                      style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Lexend'),
                    ),
                  ),
                )
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
                  itemCount: _filteredCartelle.length,
                  itemBuilder: (context, index) {
                    final folderName = _filteredCartelle[index];
                    return JambCategoryCard(
                      titolo: folderName,
                      sottotitolo: "Cartella",
                      icona: Icons.folder_rounded,
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => ExplorerView(
                            titolo: folderName,
                            cartelle: const [], // Ora si apre come cartella VUOTA
                            percorso: _fullPath,
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
          Icon(icon, size: 18, color: isLast ? const Color(0xFF25315B) : const Color(0xFF64748B)),
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
