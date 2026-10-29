import 'package:flutter/material.dart';
import 'package:jamb/core/categoria_evento_colori.dart';

/// Etichette colorate delle categorie di un evento (domini del Programma
/// d'Unità o «Altro»), usate negli elenchi e nel dettaglio.
class EtichetteCategorie extends StatelessWidget {
  final List<String> categorie;

  const EtichetteCategorie({super.key, required this.categorie});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: categorie.map((cat) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: sfondoCategoria(cat),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cat,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: coloreCategoria(cat),
            ),
          ),
        );
      }).toList(),
    );
  }
}
