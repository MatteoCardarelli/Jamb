import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/ui/core/widgets/jamb_apri_file.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';
import 'package:jamb/ui/core/widgets/jamb_errore_in_linea.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/documenti/widgets/recent_document_card.dart';
import 'package:jamb/ui/explorer/view_model/explorer_view_model.dart';
import 'package:jamb/ui/explorer/widgets/explorer_screen.dart';

/// Moduli della Modulistica Uscite proposti alla creazione di un evento
/// (es. autorizzazioni, scheda medica): i file della radice, apribili con un
/// tocco, e il collegamento a tutta la modulistica. Se la modulistica è
/// vuota la sezione non compare.
class ModulisticaSuggerita extends StatelessWidget {
  /// Moduli mostrati al massimo; gli altri sono in «Tutta la modulistica».
  static const int massimo = 4;

  const ModulisticaSuggerita({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExplorerViewModel(
        repository: context.read<IDocumentoRepository>(),
        archivio: ArchivioDocumenti.modulistica,
        titolo: ArchivioDocumenti.modulistica.titolo,
      ),
      child: const _ModulisticaView(),
    );
  }
}

class _ModulisticaView extends StatelessWidget {
  const _ModulisticaView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExplorerViewModel>();
    if (viewModel.isLoading) return const SizedBox.shrink();
    if (!viewModel.haErrore && viewModel.contenutoFiltrato.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const JambEtichettaCampo('Modulistica per l\'uscita'),
        if (viewModel.haErrore)
          JambErroreInLinea(
            messaggio: 'Modulistica non disponibile: ${viewModel.errore}',
            onRiprova: viewModel.refresh,
          )
        else ...[
          for (final doc in viewModel.file.take(ModulisticaSuggerita.massimo))
            RecentDocumentCard(
              titolo: doc.nome,
              info: viewModel.sottotitolo(doc),
              tipo: doc.tipo,
              onTap: doc.apribile
                  ? () => apriFile(context, () => viewModel.urlFile(doc))
                  : null,
            ),
          JambPulsanteSecondario(
            icona: Icons.assignment_rounded,
            etichetta: 'Tutta la modulistica',
            onTap: () => ExplorerScreen.apri(context, ArchivioDocumenti.modulistica),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
