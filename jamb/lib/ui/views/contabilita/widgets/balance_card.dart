import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double saldo;

  const BalanceCard({
    super.key,
    this.saldo = 1248.50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF000066),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "SALDO ATTUALE",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC107).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              "€${saldo.toStringAsFixed(2).replaceAll('.', ',')}",
              style: const TextStyle(
                color: Color(0xFF000066),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
