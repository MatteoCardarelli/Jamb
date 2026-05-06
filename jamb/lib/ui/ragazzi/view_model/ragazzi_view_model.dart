import 'package:flutter/material.dart';
import 'package:jamb/ui/dettaglio_ragazzo/widgets/specialita_widget.dart';

class RagazzoData {
  final String nome;
  final String squadriglia;
  final String ruolo;
  final String tappa;
  final bool hasAlert;
  final List<Specialita> specialita;

  const RagazzoData({
    required this.nome,
    required this.squadriglia,
    required this.ruolo,
    required this.tappa,
    required this.hasAlert,
    required this.specialita,
  });
}

class RagazziViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  // Dati di esempio (Da migrare in un Provider nella Fase 3)
  final List<RagazzoData> _tuttiRagazzi = [
    RagazzoData(
      nome: "Marco Rossi",
      squadriglia: "Volpi",
      ruolo: "Capo Squadriglia",
      tappa: "Responsabilità",
      hasAlert: true,
      specialita: [
        Specialita(
          nome: "Infermiere",
          prove: [
            Prova(descrizione: "Kit di primo soccorso", completata: true),
            Prova(descrizione: "Fasciatura d'emergenza", completata: false),
            Prova(descrizione: "Posizione laterale sicura", completata: false),
          ],
        ),
      ],
    ),
    RagazzoData(
      nome: "Giulia Bianchi",
      squadriglia: "Aquile",
      ruolo: "Vice Capo",
      tappa: "Scoperta",
      hasAlert: false,
      specialita: [
        Specialita(
          nome: "Cuoco",
          prove: [
            Prova(descrizione: "Pasto completo da campo", completata: true),
            Prova(descrizione: "Gestione fuoco da campo", completata: true),
            Prova(descrizione: "Pane su stecco", completata: false),
          ],
        ),
      ],
    ),
    RagazzoData(
      nome: "Luca Verdi",
      squadriglia: "Volpi",
      ruolo: "Esploratore",
      tappa: "Competenza",
      hasAlert: true,
      specialita: [
        Specialita(
          nome: "Cuoco",
          prove: [
            Prova(descrizione: "Pasto", completata: true),
            Prova(descrizione: "Fuoco", completata: true),
            Prova(descrizione: "Pane", completata: true),
          ],
          dataRaggiunta: DateTime(2026, 3, 10),
        ),
      ],
    ),
    RagazzoData(
      nome: "Sara Neri",
      squadriglia: "Aquile",
      ruolo: "Squadrigliere",
      tappa: "Scoperta",
      hasAlert: false,
      specialita: [],
    ),
    RagazzoData(
      nome: "Andrea Marino",
      squadriglia: "Pantere",
      ruolo: "Capo Squadriglia",
      tappa: "Responsabilità",
      hasAlert: true,
      specialita: [
        Specialita(
          nome: "Fotografo",
          prove: [
            Prova(descrizione: "Portfolio da campo", completata: true),
            Prova(descrizione: "Reportage evento", completata: true),
            Prova(descrizione: "Stampa e montaggio", completata: true),
          ],
          dataRaggiunta: DateTime(2026, 1, 15),
        ),
      ],
    ),
  ];

  String? _squadrigliaFiltro;
  bool _alertFiltro = false;

  RagazziViewModel() {
    searchController.addListener(() {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String get searchQuery => searchController.text;
  String? get squadrigliaFiltro => _squadrigliaFiltro;
  bool get alertFiltro => _alertFiltro;

  List<String> get squadriglie {
    final set = _tuttiRagazzi.map((r) => r.squadriglia).toSet().toList()..sort();
    return set;
  }

  List<RagazzoData> get ragazziFiltrati {
    final query = searchQuery.toLowerCase().trim();
    return _tuttiRagazzi.where((r) {
      final matchText = query.isEmpty ||
          r.nome.toLowerCase().contains(query) ||
          r.squadriglia.toLowerCase().contains(query);

      final matchSquadriglia = _squadrigliaFiltro == null ||
          r.squadriglia.toLowerCase() == _squadrigliaFiltro!.toLowerCase();

      final matchAlert = !_alertFiltro || r.hasAlert;

      return matchText && matchSquadriglia && matchAlert;
    }).toList();
  }

  void setSquadrigliaFiltro(String? sq) {
    _squadrigliaFiltro = sq;
    notifyListeners();
  }

  void setAlertFiltro(bool alert) {
    _alertFiltro = alert;
    notifyListeners();
  }
}
