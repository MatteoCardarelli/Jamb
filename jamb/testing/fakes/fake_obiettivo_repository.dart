import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';
import 'package:jamb/domain/repositories/obiettivo_repository.dart';

/// Repository degli obiettivi finto (in memoria): un obiettivo per ciascun
/// dominio indicato.
class FakeObiettivoRepository implements IObiettivoRepository {
  final List<String> domini;
  FakeObiettivoRepository(this.domini);

  @override
  Future<List<Obiettivo>> getObiettivi() async => domini
      .map((d) => Obiettivo(
            id: d,
            dominio: d,
            descrizione: '',
            grado: 3,
            colore: const Color(0xFF1D2660),
            icona: Icons.star_rounded,
          ))
      .toList();

  @override
  Future<void> salvaObiettivo(Obiettivo obiettivo) async {}

  @override
  Future<void> eliminaObiettivo(String id) async {}
}
