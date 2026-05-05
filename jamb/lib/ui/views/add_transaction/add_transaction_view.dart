import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/back_action_button.dart';
import 'widgets/transaction_header.dart';
import 'widgets/transaction_details_cards.dart';
import 'widgets/receipt_upload_card.dart';


class AddTransactionView extends StatelessWidget {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false, // SFONDO DI NUOVO FISSO
      backgroundColor: Colors.transparent,
      body: EmptyBackgroundScreen(
        currentIndex: 2,
        resizeToAvoidBottomInset: false, // SFONDO DI NUOVO FISSO
        child: Stack(
          children: [
            // Contenuto Scorrevole
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nuova Transazione",
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // WIDGET SUPERIORE (Importo Editabile)
                  const TransactionHeader(),

                  const SizedBox(height: 16),

                  // CARTE DETTAGLI (Data e Categoria)
                  const TransactionDetailsCards(),

                  const SizedBox(height: 16),

                  // CARICA SCONTRINO
                  const ReceiptUploadCard(),
                ],
              ),
            ),

            // Barra di Azione Inferiore (Flottante)
            Positioned(
              bottom: 130, // Sopra la barra di navigazione
              left: 20,
              right: 20,
              child: Row(
                children: [
                  const BackActionButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000066),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "SALVA TRANSAZIONE",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderField(String hint, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF000066)),
          const SizedBox(width: 12),
          Text(
            hint,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}
