import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/domain/entities/documento.dart';
import 'package:jamb/ui/core/widgets/jamb_category_card.dart';
import 'package:jamb/ui/documenti/widgets/tipo_documento_ui.dart';
import 'package:jamb/ui/explorer/view_model/explorer_view_model.dart';

/// Griglia di cartelle e file di un archivio.
///
/// Un tocco apre, o seleziona quando la selezione è attiva. Con
/// [puoModificare], il tocco prolungato seleziona l'elemento e, spostando il
/// dito, ne inizia il trascinamento con tutta la selezione: rilasciandola su
/// una cartella viene chiamato [onRilascia].
class GrigliaDocumenti extends StatelessWidget {
  final bool puoModificare;
  final ValueChanged<Documento> onApri;
  final ValueChanged<Documento> onRilascia;

  const GrigliaDocumenti({
    super.key,
    required this.puoModificare,
    required this.onApri,
    required this.onRilascia,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExplorerViewModel>();
    final documenti = viewModel.contenutoFiltrato;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: documenti.length,
      itemBuilder: (context, index) => _Cella(
        documento: documenti[index],
        viewModel: viewModel,
        puoModificare: puoModificare,
        onApri: onApri,
        onRilascia: onRilascia,
      ),
    );
  }
}

class _Cella extends StatelessWidget {
  final Documento documento;
  final ExplorerViewModel viewModel;
  final bool puoModificare;
  final ValueChanged<Documento> onApri;
  final ValueChanged<Documento> onRilascia;

  const _Cella({
    required this.documento,
    required this.viewModel,
    required this.puoModificare,
    required this.onApri,
    required this.onRilascia,
  });

  Widget _carta({bool evidenziata = false}) => JambCategoryCard(
    titolo: documento.nome,
    sottotitolo: viewModel.sottotitolo(documento),
    icona: documento.tipo.icona,
    selezionata: viewModel.isSelezionato(documento),
    evidenziata: evidenziata,
    onTap: viewModel.inSelezione
        ? (puoModificare ? () => viewModel.alternaSelezione(documento) : null)
        : () => onApri(documento),
  );

  Widget _trascinabile({bool evidenziata = false}) =>
      LongPressDraggable<String>(
        data: documento.id,
        onDragStarted: () => viewModel.includiNellaSelezione(documento),
        feedback: AnteprimaTrascinamento(
          viewModel: viewModel,
          documento: documento,
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: _carta()),
        child: _carta(evidenziata: evidenziata),
      );

  @override
  Widget build(BuildContext context) {
    if (!puoModificare) return _carta();
    if (!documento.isCartella) return _trascinabile();
    return DragTarget<String>(
      // Il bersaglio sotto il dito viene interrogato prima che il trascinamento
      // inizi, quando la cartella presa non risulta ancora selezionata.
      onWillAcceptWithDetails: (dettagli) =>
          dettagli.data != documento.id && viewModel.puoRicevere(documento),
      onAcceptWithDetails: (_) => onRilascia(documento),
      builder: (_, candidati, _) =>
          _trascinabile(evidenziata: candidati.isNotEmpty),
    );
  }
}

/// Ciò che segue il dito durante il trascinamento. Sta nell'overlay, fuori
/// dal Provider, e ascolta direttamente il ViewModel: la selezione si
/// aggiorna proprio mentre il trascinamento inizia.
class AnteprimaTrascinamento extends StatelessWidget {
  final ExplorerViewModel viewModel;
  final Documento documento;

  const AnteprimaTrascinamento({
    super.key,
    required this.viewModel,
    required this.documento,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (_, _) {
        final n = viewModel.numeroSelezionati;
        return Material(
          color: const Color(0xFF1D2660),
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  n > 1 ? Icons.copy_all_rounded : documento.tipo.icona,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    n > 1 ? '$n elementi' : documento.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Barra delle azioni sulla selezione: quanti elementi, seleziona tutto,
/// sposta, rinomina (con un solo elemento), elimina, chiudi.
class BarraSelezione extends StatelessWidget {
  final int numero;
  final VoidCallback onChiudi;
  final VoidCallback onTutti;
  final VoidCallback onSposta;
  final VoidCallback onRinomina;
  final VoidCallback onElimina;

  const BarraSelezione({
    super.key,
    required this.numero,
    required this.onChiudi,
    required this.onTutti,
    required this.onSposta,
    required this.onRinomina,
    required this.onElimina,
  });

  @override
  Widget build(BuildContext context) {
    const blu = Color(0xFF1D2660);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Annulla selezione',
            icon: const Icon(Icons.close_rounded, color: blu),
            onPressed: onChiudi,
          ),
          Expanded(
            child: Text(
              numero == 1 ? '1 selezionato' : '$numero selezionati',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: blu,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Seleziona tutto',
            icon: const Icon(Icons.select_all_rounded, color: blu),
            onPressed: onTutti,
          ),
          IconButton(
            tooltip: 'Sposta in…',
            icon: const Icon(Icons.drive_file_move_outline, color: blu),
            onPressed: onSposta,
          ),
          if (numero == 1)
            IconButton(
              tooltip: 'Rinomina',
              icon: const Icon(
                Icons.drive_file_rename_outline_rounded,
                color: blu,
              ),
              onPressed: onRinomina,
            ),
          IconButton(
            tooltip: 'Elimina',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFB91C1C),
            ),
            onPressed: onElimina,
          ),
        ],
      ),
    );
  }
}
