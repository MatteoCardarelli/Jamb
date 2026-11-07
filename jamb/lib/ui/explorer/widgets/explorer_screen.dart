import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_apri_file.dart';
import 'package:jamb/ui/core/widgets/jamb_intestazione.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_category_card.dart';
import 'package:jamb/ui/core/widgets/jamb_expandable_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_menu.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';
import 'package:jamb/ui/documenti/widgets/tipo_documento_ui.dart';
import 'package:jamb/ui/explorer/view_model/explorer_view_model.dart';

/// Schermata per l'esplorazione di un archivio di documenti (drive o
/// libreria): cartelle e file di un livello, ricerca e percorso.
///
/// Un tocco apre una cartella o un file; il tocco prolungato offre di
/// rinominarlo o eliminarlo. Il pulsante «+» crea cartelle e carica file,
/// solo per chi può modificare l'archivio.
class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  /// Apre la cartella [parentId] di [archivio] (la radice se `null`).
  static Future<void> apri(
    BuildContext context,
    ArchivioDocumenti archivio, {
    String? titolo,
    String? parentId,
    List<String> percorsoPrecedente = const [],
  }) {
    final repository = context.read<IDocumentoRepository>();
    return Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider(
        create: (_) => ExplorerViewModel(
          repository: repository,
          archivio: archivio,
          titolo: titolo ?? archivio.titolo,
          parentId: parentId,
          percorsoPrecedente: percorsoPrecedente,
        ),
        child: const ExplorerScreen(),
      ),
      transitionDuration: Duration.zero,
    ));
  }

  Future<void> _nuovaCartella(BuildContext context, ExplorerViewModel viewModel) async {
    final nome = await JambDialogs.chiediNome(
      context,
      titolo: "Nuova cartella",
      icona: Icons.create_new_folder_rounded,
      conferma: "CREA",
      valida: erroreNomeDocumento,
    );
    if (nome != null && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.creaCartella(nome));
    }
  }

  Future<void> _caricaFile(BuildContext context, ExplorerViewModel viewModel) async {
    final scelta = await FilePicker.pickFiles(withData: true);
    final file = scelta?.files.single;
    if (file == null || file.bytes == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text("Caricamento di ${file.name}…")));
    final caricato = await eseguiConFeedback(
      context,
      () => viewModel.caricaFile(FileDaCaricare(nome: file.name, byte: file.bytes!)),
    );
    if (caricato) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("${file.name} caricato.")));
    }
  }

  void _apri(BuildContext context, ExplorerViewModel viewModel, Documento doc) {
    if (doc.isCartella) {
      apri(
        context,
        viewModel.archivio,
        titolo: doc.nome,
        parentId: doc.id,
        percorsoPrecedente: viewModel.fullPath,
      );
    } else if (doc.apribile) {
      apriFile(context, () => viewModel.urlFile(doc));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Questo documento non ha un file da aprire."),
      ));
    }
  }

  /// Menu del tocco prolungato: rinomina ed elimina.
  void _opzioni(BuildContext context, ExplorerViewModel viewModel, Documento doc) {
    mostraMenuJamb(
      context,
      titolo: doc.nome,
      sottotitolo: viewModel.sottotitolo(doc),
      voci: (_) => [
        JambVoceMenu(
          icona: Icons.drive_file_rename_outline_rounded,
          etichetta: 'Rinomina',
          onTap: () => _rinomina(context, viewModel, doc),
        ),
        JambVoceMenu(
          icona: Icons.delete_outline_rounded,
          etichetta: 'Elimina',
          pericolosa: true,
          onTap: () => _elimina(context, viewModel, doc),
        ),
      ],
    );
  }

  Future<void> _rinomina(BuildContext context, ExplorerViewModel viewModel, Documento doc) async {
    final nome = await JambDialogs.chiediNome(
      context,
      titolo: "Rinomina",
      icona: Icons.drive_file_rename_outline_rounded,
      conferma: "SALVA",
      iniziale: doc.nome,
      valida: erroreNomeDocumento,
    );
    if (nome != null && nome != doc.nome && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.rinomina(doc, nome));
    }
  }

  Future<void> _elimina(BuildContext context, ExplorerViewModel viewModel, Documento doc) async {
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: doc.isCartella ? "Elimina cartella" : "Elimina file",
      messaggio: doc.isCartella
          ? "Vuoi eliminare \"${doc.nome}\" con tutto il suo contenuto? L'azione non è reversibile."
          : "Vuoi eliminare \"${doc.nome}\"? L'azione non è reversibile.",
    );
    if (conferma && context.mounted) {
      await eseguiConFeedback(context, () => viewModel.elimina(doc));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExplorerViewModel>();
    final puoModificare = context.select<SessionService, bool>(
      (s) => s.permessi.puoModificare(viewModel.archivio),
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: EmptyBackgroundScreen(
        currentIndex: 2, // Icona documenti selezionata
        floatingActionButton: puoModificare
            ? JambExpandableFab(
                onCreateFolder: () => _nuovaCartella(context, viewModel),
                onUploadDocument: () => _caricaFile(context, viewModel),
              )
            : null,
        child: SingleChildScrollView(
          // Padding top di 170 per stare sotto la TopBar
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // La freccia risale di un livello (dalla prima cartella torna all'hub Documenti).
              JambIntestazione(titolo: viewModel.titolo),
              const SizedBox(height: 24),

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
                              for (int i = 0; i < steps; i++) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // GRIGLIA CONTENUTO (cartelle + file)
              if (viewModel.isLoading && viewModel.contenutoFiltrato.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (viewModel.haErrore)
                JambStatoErrore(
                  messaggio: viewModel.errore!,
                  onRiprova: viewModel.refresh,
                )
              else if (viewModel.contenutoFiltrato.isEmpty)
                _buildEmptyState(vuota: viewModel.searchController.text.trim().isEmpty)
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
                  itemCount: viewModel.contenutoFiltrato.length,
                  itemBuilder: (context, index) {
                    final doc = viewModel.contenutoFiltrato[index];
                    return JambCategoryCard(
                      titolo: doc.nome,
                      sottotitolo: viewModel.sottotitolo(doc),
                      icona: doc.tipo.icona,
                      onTap: () => _apri(context, viewModel, doc),
                      onLongPress: puoModificare ? () => _opzioni(context, viewModel, doc) : null,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Stato visualizzato quando la cartella è vuota o la ricerca non trova nulla.
  Widget _buildEmptyState({required bool vuota}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Text(
          vuota ? "Questa cartella è vuota" : "Nessun risultato trovato",
          style: const TextStyle(
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
