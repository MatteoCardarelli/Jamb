import 'package:flutter/material.dart';

class TransactionHeader extends StatefulWidget {
  const TransactionHeader({super.key});

  @override
  State<TransactionHeader> createState() => _TransactionHeaderState();
}

class _TransactionHeaderState extends State<TransactionHeader> {
  bool isUscita = true;
  final TextEditingController _amountCtrl = TextEditingController(text: "0,00");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle Uscita / Entrata
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
                  onTap: () => setState(() => isUscita = true),
                ),
              ),
              Expanded(
                child: _buildToggleButton(
                  label: "Entrata",
                  icon: Icons.add_circle_rounded,
                  isSelected: !isUscita,
                  onTap: () => setState(() => isUscita = false),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Display Importo EDITABILE
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white, // SFONDO BIANCO SOLIDO
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
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
                      color: Color(0xFF000066),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF000066),
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
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

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
              color: isSelected ? const Color(0xFF000066) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF000066) : const Color(0xFF94A3B8),
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
