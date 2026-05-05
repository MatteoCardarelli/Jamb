import 'package:flutter/material.dart';

/// Widget superiore della vista AddTransaction.
/// Gestisce il toggle tra Entrata/Uscita e l'input numerico dell'importo.
class TransactionHeader extends StatefulWidget {
  const TransactionHeader({super.key});

  @override
  State<TransactionHeader> createState() => _TransactionHeaderState();
}

class _TransactionHeaderState extends State<TransactionHeader> {
  bool isUscita = true;
  final TextEditingController _amountCtrl = TextEditingController(text: "0,00");
  final FocusNode _amountFocus = FocusNode(); // Nodo di focus per controllo manuale

  @override
  void dispose() {
    _amountCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- TOGGLE TIPO TRANSAZIONE (Uscita / Entrata) ---
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  label: "Uscita",
                  icon: Icons.remove_circle_rounded,
                  isSelected: isUscita,
                  onTap: () {
                    _amountFocus.unfocus(); // Toglie focus se si preme il toggle
                    setState(() => isUscita = true);
                  },
                ),
              ),
              Expanded(
                child: _buildToggleButton(
                  label: "Entrata",
                  icon: Icons.add_circle_rounded,
                  isSelected: !isUscita,
                  onTap: () {
                    _amountFocus.unfocus(); // Toglie focus se si preme il toggle
                    setState(() => isUscita = false);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- DISPLAY IMPORTO EDITABILE ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                "IMPORTO TOTALE",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "€",
                    style: TextStyle(
                      color: Color(0xFF1D2660),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      focusNode: _amountFocus,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1D2660),
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: "0,00",
                        hintStyle: TextStyle(color: Color(0xFFE2E8F0)),
                      ),
                      onTap: () {
                        // Se l'utente clicca esplicitamente, prendi il focus
                        _amountFocus.requestFocus();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Costruisce un pulsante di toggle per la selezione del tipo di transazione
  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF1D2660) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1D2660) : const Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
