import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/entities/file_da_caricare.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_apri_file.dart';
import 'package:jamb/ui/core/widgets/jamb_intestazione.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_expandable_fab.dart';
import 'package:jamb/ui/core/widgets/jamb_dialogs.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_stato_errore.dart';
import 'package:jamb/ui/explorer/view_model/explorer_view_model.dart';
import 'package:jamb/ui/explorer/widgets/griglia_documenti.dart';

/// Schermata per l'esplorazione di un archivio di documenti (drive o
/// libreria): cartelle e file di un livello, ricerca e percorso.
///
/// Un tocco apre una cartella o un file. Per chi può modificare l'archivio, il
/// tocco prolungato seleziona l'elemento e permette di trascinare la selezione
/// su una cartella o su un livello del percorso; la barra della selezione
/// offre di spostare, rinominare ed eliminare. Il pulsante «+» crea cartelle e
/// carica file.
class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  /// Apre la cartella [parentId] di [archivio] (la radice se `null`).
  static Future<void> apri(
    BuildContext context,
    ArchivioDocumenti archivio, {
    String? titolo,
    String? parentId,
    List<String> percorsoPrecedente = const [],
    List<String?> idPercorsoPrecedente = const [],
  }) {
    final repository = context.read<IDocumentoRepository>();
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangeNotifierProvider(
              create: (_) => ExplorerViewModel(
                repository: repository,
                archivio: archivio,
                titolo: titolo ?? archivio.titolo,
                parentId: parentId,
                percorsoPrecedente: percorsoPrecedente,
                idPercorsoPrecedente: idPercorsoPrecedente,
              ),
              child: const ExplorerScreen(),
            ),
        transitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _nuovaCartella(
    BuildContext context,
    ExplorerViewModel viewModel,
  ) async {
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

  Future<void> _caricaFile(
    BuildContext context,
    ExplorerViewModel viewModel,
  ) async {
    final scelta = await FilePicker.pickFiles(withData: true);
    final file = scelta?.files.single;
    if (file == null || file.bytes == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text("Caricamento di ${file.name}…")),
    );
    final caricato = await eseguiConFeedback(
      context,
      () => viewModel.caricaFile(
        FileDaCaricare(nome: file.name, byte: file.bytes!),
      ),
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
        idPercorsoPrecedente: viewModel.idPercorso,
      );
    } else if (doc.apribile) {
      apriFile(context, () => viewModel.urlFile(doc));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Questo documento non ha un file da aprire."),
        ),
      );
    }
  }

  /// Sposta la selezione nella cartella [id] (`null` = radice), di nome [nome].
  Future<void> _spostaIn(
    BuildContext context,
    ExplorerViewModel viewModel,
    String? id,
    String nome,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    var spostati = 0;
    final riuscito = await eseguiConFeedback(context, () async {
      spostati = await viewModel.spostaSelezione(id);
    });
    if (riuscito && spostati > 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            spostati == 1
                ? "Spostato in $nome."
                : "$spostati elementi spostati in $nome.",
          ),
        ),
      );
    }
  }

  /// Chiede dove spostare la selezione, tra tutte le cartelle dell'archivio.
  Future<void> _scegliDestinazione(
    BuildContext context,
    ExplorerViewModel viewModel,
  ) async {
    List<VoceCartella> voci = const [];
    final lette = await eseguiConFeedback(context, () async {
      voci = await viewModel.destinazioni();
    });
    if (!lette || !context.mounted) return;
    if (voci.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Non ci sono altre cartelle in cui spostare."),
        ),
      );
      return;
    }
    final scelta = await JambDialogs.scegli<VoceCartella>(
      context,
      titolo: "Sposta in",
      messaggio: "Scegli la cartella di destinazione.",
      opzioni: [for (final v in voci) ("${'· ' * v.livello}${v.nome}", v)],
    );
    if (scelta != null && context.mounted) {
      await _spostaIn(context, viewModel, scelta.id, scelta.nome);
    }
  }

  Future<void> _rinomina(
    BuildContext context,
    ExplorerViewModel viewModel,
    Documento doc,
  ) async {
    final nome = await JambDialogs.chiediNome(
      context,
      titolo: "Rinomina",
      icona: Icons.drive_file_rename_outline_rounded,
      conferma: "SALVA",
      iniziale: doc.nome,
      valida: erroreNomeDocumento,
    );
    if (nome != null && nome != doc.nome && context.mounted) {
      final riuscito = await eseguiConFeedback(
        context,
        () => viewModel.rinomina(doc, nome),
      );
      if (riuscito) viewModel.annullaSelezione();
    }
  }

  Future<void> _eliminaSelezione(
    BuildContext context,
    ExplorerViewModel viewModel,
  ) async {
    final conCartelle = viewModel.selezionati.any((d) => d.isCartella);
    final n = viewModel.numeroSelezionati;
    final conferma = await JambDialogs.confermaEliminazione(
      context,
      titolo: n == 1 ? "Elimina" : "Elimina $n elementi",
      messaggio: conCartelle
          ? "Le cartelle verranno eliminate con tutto il loro contenuto. L'azione non è reversibile."
          : "L'azione non è reversibile.",
    );
    if (conferma && context.mounted) {
      await eseguiConFeedback(context, viewModel.eliminaSelezione);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExplorerViewModel>();
    final puoModificare = context.select<SessionService, bool>(
      (s) => s.permessi.puoModificare(viewModel.archivio),
    );

    // Il tasto indietro chiude prima la selezione, poi la cartella.
    return PopScope(
      canPop: !viewModel.inSelezione,
      onPopInvokedWithResult: (riuscito, _) {
        if (!riuscito) viewModel.annullaSelezione();
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: EmptyBackgroundScreen(
          currentIndex: 2, // Icona documenti selezionata
          floatingActionButton: puoModificare && !viewModel.inSelezione
              ? JambExpandableFab(
                  onCreateFolder: () => _nuovaCartella(context, viewModel),
                  onUploadDocument: () => _caricaFile(context, viewModel),
                )
              : null,
          child: SingleChildScrollView(
            // Padding top di 170 per stare sotto la TopBar
            padding: const EdgeInsets.only(
              top: 170,
              left: 20,
              right: 20,
              bottom: 120,
            ),
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
                        onTap: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                      ),
                      ...List.generate(viewModel.fullPath.length, (index) {
                        final isLast = index == viewModel.fullPath.length - 1;
                        return Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            // I livelli superiori accettano anche la selezione trascinata.
                            DragTarget<String>(
                              onWillAcceptWithDetails: (_) =>
                                  puoModificare && !isLast,
                              onAcceptWithDetails: (_) => _spostaIn(
                                context,
                                viewModel,
                                viewModel.idPercorso[index],
                                viewModel.fullPath[index],
                              ),
                              builder: (_, candidati, _) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: candidati.isNotEmpty
                                      ? const Color(0xFFE8EAF6)
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _buildBreadcrumbItem(
                                  label: viewModel.fullPath[index],
                                  icon: isLast
                                      ? Icons.folder_rounded
                                      : Icons.folder_outlined,
                                  isLast: isLast,
                                  onTap: isLast
                                      ? null
                                      : () {
                                          // Navigazione a ritroso: torna indietro di N posizioni nella stack delle rotte
                                          int steps =
                                              viewModel.fullPath.length -
                                              1 -
                                              index;
                                          for (int i = 0; i < steps; i++) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (viewModel.inSelezione) ...[
                  BarraSelezione(
                    numero: viewModel.numeroSelezionati,
                    onChiudi: viewModel.annullaSelezione,
                    onTutti: viewModel.selezionaTutti,
                    onSposta: () => _scegliDestinazione(context, viewModel),
                    onRinomina: () => _rinomina(
                      context,
                      viewModel,
                      viewModel.selezionati.single,
                    ),
                    onElimina: () => _eliminaSelezione(context, viewModel),
                  ),
                  const SizedBox(height: 12),
                ] else if (puoModificare &&
                    viewModel.contenutoFiltrato.isNotEmpty) ...[
                  const Text(
                    "Tieni premuto per selezionare o trascinare",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

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
                  viewModel.searchController.text.trim().isEmpty
                      ? const JambTestoVuoto(
                          "Questa cartella è vuota",
                          icona: Icons.folder_open_rounded,
                          centrato: true,
                        )
                      : const JambTestoVuoto(
                          "Nessun risultato trovato",
                          icona: Icons.search_off_rounded,
                          centrato: true,
                        )
                else
                  GrigliaDocumenti(
                    puoModificare: puoModificare,
                    onApri: (doc) => _apri(context, viewModel, doc),
                    onRilascia: (cartella) => _spostaIn(
                      context,
                      viewModel,
                      cartella.id,
                      cartella.nome,
                    ),
                  ),
              ],
            ),
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
    VoidCallback? onTap,
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
