import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/presenza.dart';

/// Etichetta e colore di uno stato dell'appello, usati nell'appello e nello
/// storico del ragazzo.
extension StatoPresenzaUi on StatoPresenza {
  String get etichetta => switch (this) {
        StatoPresenza.presente => 'Presente',
        StatoPresenza.assente => 'Assente',
        StatoPresenza.giustificato => 'Giustificato',
      };

  Color get colore => switch (this) {
        StatoPresenza.presente => const Color(0xFF16A34A),
        StatoPresenza.assente => const Color(0xFFE11D48),
        StatoPresenza.giustificato => const Color(0xFF64748B),
      };
}
