import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/contabilita/widgets/add_transaction/transaction_header.dart';
import 'package:jamb/ui/contabilita/widgets/add_transaction/transaction_details_cards.dart';
import 'package:jamb/ui/contabilita/widgets/add_transaction/receipt_upload_card.dart';
import 'package:jamb/ui/contabilita/view_model/add_transaction_view_model.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';
import 'package:jamb/domain/entities/transazione.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';

/// Schermata per l'inserimento di una nuova transazione (Entrata o Uscita).
/// Organizzata in sezioni: Header (Importo), Dettagli (Data/Categoria/Note) e Allegati (Scontrino).
class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  /// Apre il form e, se l'utente conferma, salva la transazione mostrando
  /// l'eventuale errore. Usato dalla Contabilità e dalle azioni rapide della Home.
  static Future<void> apri(BuildContext context) async {
    final contabilita = context.read<ContabilitaViewModel>();
    final transazione = await Navigator.of(context).push<Transazione>(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider(
        create: (_) => AddTransactionViewModel(),
        child: const AddTransactionScreen(),
      ),
      transitionDuration: Duration.zero,
    ));

    if (transazione != null && context.mounted) {
      await eseguiConFeedback(context, () => contabilita.addTransaction(transazione));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddTransactionViewModel>();

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false, // Evita che lo sfondo si sposti con la tastiera
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 2, // Indice per la sezione contabilità
        resizeToAvoidBottomInset: false,
        child: Stack(
          children: [
            // --- CONTENUTO SCORREVOLE ---
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 170, 20, 250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nuova Transazione",
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SEZIONE IMPORTO (Editabile)
                  const TransactionHeader(),
                  const SizedBox(height: 16),

                  // SEZIONE DETTAGLI (Data, Categoria, Note)
                  const TransactionDetailsCards(),
                  const SizedBox(height: 16),

                  // SEZIONE ALLEGATI (Scontrino)
                  const ReceiptUploadCard(),
                ],
              ),
            ),

            // --- BARRA DI AZIONE INFERIORE (Flottante) ---
            Positioned(
              bottom: 130, // Posizionata sopra la barra di navigazione
              left: 20,
              right: 20,
              child: JambBarraAzioni(
                etichetta: "SALVA TRANSAZIONE",
                icona: Icons.save_rounded,
                onPressed: () {
                  final transazione = viewModel.buildTransaction();
                  if (transazione != null) {
                    Navigator.of(context).pop(transazione);
                  } else {
                    // Opzionale: mostrare un errore se l'importo è 0
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Inserisci un importo valido")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
