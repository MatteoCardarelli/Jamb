import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/specialita_widget.dart';
import 'package:jamb/ui/views/ragazzi/widgets/ragazzo_card.dart';
import 'package:jamb/ui/views/ragazzi/widgets/ragazzi_search_bar.dart';
import 'package:jamb/ui/views/ragazzi/widgets/ragazzi_filters.dart';

// ─── Modello temporaneo (da sostituire col db) ─────────────────────────────

class _RagazzoData {
  final String nome;
  final String squadriglia;
  final String ruolo;
  final String tappa;
  final bool hasAlert;
  final List<Specialita> specialita;

  const _RagazzoData({
    required this.nome,
    required this.squadriglia,
    required this.ruolo,
    required this.tappa,
    required this.hasAlert,
    required this.specialita,
  });
}

// ─── Mock data ──────────────────────────────────────────────────────────────

final List<_RagazzoData> _tuttiRagazzi = [
  _RagazzoData(
    nome: "Marco Rossi",
    squadriglia: "Volpi",
    ruolo: "Capo Squadriglia",
    tappa: "Responsabilità",
    hasAlert: true,
    specialita: [
      Specialita(
        nome: "Infermiere",
        icona: Icons.medical_services_outlined,
        coloreIcona: Color(0xFFF59E0B),
        prove: [
          Prova(descrizione: "Kit di primo soccorso", completata: true),
          Prova(descrizione: "Fasciatura d'emergenza", completata: false),
          Prova(descrizione: "Posizione laterale sicura", completata: false),
        ],
      ),
    ],
  ),
  _RagazzoData(
    nome: "Giulia Bianchi",
    squadriglia: "Aquile",
    ruolo: "Vice Capo",
    tappa: "Scoperta",
    hasAlert: false,
    specialita: [
      Specialita(
        nome: "Cuoco",
        icona: Icons.restaurant_outlined,
        coloreIcona: Color(0xFF16A34A),
        prove: [
          Prova(descrizione: "Pasto completo da campo", completata: true),
          Prova(descrizione: "Gestione fuoco da campo", completata: true),
          Prova(descrizione: "Pane su stecco", completata: false),
        ],
      ),
    ],
  ),
  _RagazzoData(
    nome: "Luca Verdi",
    squadriglia: "Volpi",
    ruolo: "Esploratore",
    tappa: "Competenza",
    hasAlert: true,
    specialita: [
      Specialita(
        nome: "Cuoco",
        icona: Icons.restaurant_outlined,
        coloreIcona: Color(0xFF16A34A),
        prove: [
          Prova(descrizione: "Pasto", completata: true),
          Prova(descrizione: "Fuoco", completata: true),
          Prova(descrizione: "Pane", completata: true),
        ],
        dataRaggiunta: DateTime(2026, 3, 10),
      ),
    ],
  ),
  _RagazzoData(
    nome: "Sara Neri",
    squadriglia: "Aquile",
    ruolo: "Squadrigliere",
    tappa: "Scoperta",
    hasAlert: false,
    specialita: [],
  ),
  _RagazzoData(
    nome: "Andrea Marino",
    squadriglia: "Pantere",
    ruolo: "Capo Squadriglia",
    tappa: "Responsabilità",
    hasAlert: true,
    specialita: [
      Specialita(
        nome: "Fotografo",
        icona: Icons.photo_camera_outlined,
        coloreIcona: Color(0xFF2563EB),
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

// ─── View ───────────────────────────────────────────────────────────────────

class RagazziView extends StatefulWidget {
  const RagazziView({super.key});

  @override
  State<RagazziView> createState() => _RagazziViewState();
}

class _RagazziViewState extends State<RagazziView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _squadrigliaFiltro;
  bool _alertFiltro = false;

  // Squadriglie uniche dai mock
  List<String> get _squadriglie {
    final set = _tuttiRagazzi.map((r) => r.squadriglia).toSet().toList()..sort();
    return set;
  }

  List<_RagazzoData> get _ragazziFiltrati {
    final query = _searchCtrl.text.toLowerCase().trim();
    return _tuttiRagazzi.where((r) {
      // Filtro testo: nome o squadriglia
      final matchText = query.isEmpty ||
          r.nome.toLowerCase().contains(query) ||
          r.squadriglia.toLowerCase().contains(query);

      // Filtro squadriglia
      final matchSquadriglia = _squadrigliaFiltro == null ||
          r.squadriglia.toLowerCase() == _squadrigliaFiltro!.toLowerCase();

      // Filtro alert medici
      final matchAlert = !_alertFiltro || r.hasAlert;

      return matchText && matchSquadriglia && matchAlert;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final risultati = _ragazziFiltrati;

    return EmptyBackgroundScreen(
      currentIndex: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RagazziSearchBar(controller: _searchCtrl),
                  const SizedBox(height: 16),

                  RagazziFilters(
                    squadrigliaSelezionata: _squadrigliaFiltro,
                    alertMediciAttivo: _alertFiltro,
                    squadriglie: _squadriglie,
                    onSquadrigliaChanged: (sq) => setState(() => _squadrigliaFiltro = sq),
                    onAlertChanged: (v) => setState(() => _alertFiltro = v),
                  ),
                  const SizedBox(height: 24),

                  if (risultati.isEmpty)
                    _buildEmpty()
                  else
                    ...risultati.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RagazzoCard(
                        nome: r.nome,
                        squadriglia: r.squadriglia.toUpperCase(),
                        ruolo: r.ruolo,
                        tappa: r.tappa,
                        hasAlert: r.hasAlert,
                        specialita: r.specialita,
                      ),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Nessun ragazzo trovato",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontFamily: 'Lexend', fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Prova a cambiare i filtri o la ricerca",
              style: TextStyle(color: Colors.grey.shade300, fontSize: 13, fontFamily: 'Lexend'),
            ),
          ],
        ),
      ),
    );
  }
}
