import 'package:flutter/material.dart';

class DettaglioRagazzoHeader extends StatelessWidget {
  final String nome;
  final String squadriglia;
  final String ruolo;
  final bool hasAlert;
  final VoidCallback? onEdit;

  const DettaglioRagazzoHeader({
    super.key,
    required this.nome,
    required this.squadriglia,
    required this.ruolo,
    required this.hasAlert,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00005C),
                          fontFamily: 'Lexend',
                        ),
                      ),
                      if (hasAlert) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.medical_services, size: 24, color: Color(0xFFE11D48)),
                      ],
                    ],
                  ),
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.more_vert, color: Color(0xFF64748B), size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      squadriglia,
                      style: const TextStyle(
                        color: Color(0xFFEA580C),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    ruolo,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 16,
                      fontFamily: 'Lexend',
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
}
