import 'package:flutter/material.dart';

/// Categoria trasversale sempre disponibile, oltre agli obiettivi dell'unità.
const String categoriaAltro = 'Altro';

/// Palette usata per distinguere visivamente le categorie tematiche.
const List<Color> _palette = [
  Color(0xFF283593),
  Color(0xFF2E7D32),
  Color(0xFFD84315),
  Color(0xFF6A1B9A),
  Color(0xFF00838F),
  Color(0xFFAD1457),
];

const Color _coloreAltro = Color(0xFF616161);

/// Colore associato a una categoria tematica.
///
/// La voce "Altro" ha sempre un colore neutro; le altre ricevono un colore
/// derivato dal nome, così la stessa categoria appare identica ovunque
/// senza doverne memorizzare il colore.
Color coloreCategoria(String categoria) {
  if (categoria.trim().toLowerCase() == categoriaAltro.toLowerCase()) {
    return _coloreAltro;
  }
  return _palette[categoria.hashCode.abs() % _palette.length];
}

/// Colore di sfondo tenue per le etichette di categoria.
Color sfondoCategoria(String categoria) =>
    coloreCategoria(categoria).withValues(alpha: 0.12);
