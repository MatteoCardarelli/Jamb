import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/core/widgets/jamb_category_card.dart';
import 'package:jamb/ui/core/widgets/jamb_apri_file.dart';
import 'package:jamb/ui/core/widgets/jamb_errore_in_linea.dart';
import 'package:jamb/ui/documenti/widgets/recent_document_card.dart';
import 'package:jamb/ui/amministrazione/widgets/amministrazione_screen.dart';
import 'package:jamb/ui/amministrazione/view_model/amministrazione_view_model.dart';
import 'package:jamb/ui/explorer/widgets/explorer_screen.dart';
import 'package:jamb/ui/contabilita/widgets/contabilita_screen.dart';
import 'package:jamb/ui/documenti/view_model/documenti_view_model.dart';
import 'package:jamb/domain/entities/documento.dart';

/// Hub centrale per la gestione dei documenti e delle sezioni amministrative.
/// Fornisce accesso rapido ai Drive condivisi, alla Contabilità, all'Amministrazione
/// e visualizza un elenco dei file modificati di recente.
class DocumentiScreen extends StatelessWidget {
  const DocumentiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupero dati per la barra di progresso del modulo Amministrazione
    final adminViewModel = Provider.of<AmministrazioneViewModel>(context);
    final int totaliRagazzi = adminViewModel.totali;
    final int ragazziOk = adminViewModel.ragazziTuttoOk;

    final viewModel = context.watch<DocumentiViewModel>();
    final categorie = viewModel.categorieFiltrate;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: EmptyBackgroundScreen(
        currentIndex: 2, // Icona documenti attiva
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARRA DI RICERCA
              JambSearchBar(
                controller: viewModel.searchController,
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
                itemCount: categorie.length,
                itemBuilder: (context, index) {
                  final cat = categorie[index];
                  
                  // Definizione dinamica della rotta di destinazione
                  VoidCallback? onTap;
                  if (cat['archivio'] case final ArchivioDocumenti archivio) {
                    onTap = () => ExplorerScreen.apri(context, archivio);
                  } else if (cat['titolo'] == "Amministrazione") {
                    onTap = () => _navigateTo(context, const AmministrazioneScreen());
                  } else if (cat['titolo'] == "Contabilità") {
                    onTap = () => _navigateTo(context, const ContabilitaScreen());
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

              // SEZIONE: DOCUMENTI RECENTI (ultimi file del Drive di Branca)
              const Text(
                "Documenti Recenti",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 12),

              if (viewModel.haErrore)
                JambErroreInLinea(
                  messaggio: 'Documenti recenti non disponibili: ${viewModel.errore}',
                  onRiprova: viewModel.ricaricaRecenti,
                )
              else if (!viewModel.isLoading && viewModel.recenti.isEmpty)
                const JambTestoVuoto("Nessun file nel Drive di Branca.")
              else
                for (final doc in viewModel.recenti)
                  RecentDocumentCard(
                    titolo: doc.nome,
                    info: viewModel.infoRecente(doc),
                    tipo: doc.tipo,
                    onTap: doc.apribile ? () => apriFile(context, () => viewModel.urlFile(doc)) : null,
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
