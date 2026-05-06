import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/obiettivo.dart';

class HomeViewModel extends ChangeNotifier {
  // Dati di esempio (Mock) per lo sviluppo.
  // TODO: Spostare in un ObiettiviProvider dedicato nella Fase 3 del refactoring.
  List<Obiettivo> _obiettivi = [
    const Obiettivo(
      id: "1",
      dominio: "Spiritualità",
      descrizione: "Rendere più consapevoli i ragazzi degli eventi cristiani che vivono",
      grado: 5,
      colore: Color(0xFF283664),
      icona: Icons.church,
    ),
    const Obiettivo(
      id: "2",
      dominio: "Abilità manuali",
      descrizione: "Costruzione della cucina da campo ad incastro",
      grado: 4,
      colore: Color(0xFF4A6849),
      icona: Icons.handyman,
    ),
    const Obiettivo(
      id: "3",
      dominio: "Forza fisica",
      descrizione: "Autonomia nello zaino e marcia",
      grado: 3,
      colore: Color(0xFFE88A42),
      icona: Icons.directions_walk,
    ),
  ];

  List<Obiettivo> get obiettivi => _obiettivi;

  void updateObiettivi(List<Obiettivo> updatedList) {
    _obiettivi = List.from(updatedList);
    notifyListeners();
  }
}
