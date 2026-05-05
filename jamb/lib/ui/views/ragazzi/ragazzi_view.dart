import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/views/dettaglio_ragazzo/widgets/specialita_widget.dart';
import 'package:jamb/ui/views/ragazzi/widgets/ragazzo_card.dart';
import 'package:jamb/ui/core/widgets/jamb_search_bar.dart';
import 'package:jamb/ui/views/ragazzi/widgets/ragazzi_filters.dart';

// --- MODELLO DATI TEMPORANEO (Mock) ---

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

// --- DATI DI ESEMPIO (Da migrare in un Provider nella Fase 3) ---

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

/// Schermata principale per la gestione e visualizzazione dell'elenco ragazzi.
/// Include funzionalità di ricerca testuale, filtraggio per squadriglia e avvisi medici.
class RagazziView extends StatefulWidget {
  const RagazziView({super.key});

  @override
  State<RagazziView> createState() => _RagazziViewState();
}

class _RagazziViewState extends State<RagazziView> {
  // Controller per la barra di ricerca
  final TextEditingController _searchCtrl = TextEditingController();
  
  // Stati dei filtri
  String? _squadrigliaFiltro;
  bool _alertFiltro = false;

  /// Estrae l'elenco unico delle squadriglie per i filtri
  List<String> get _squadriglie {
    final set = _tuttiRagazzi.map((r) => r.squadriglia).toSet().toList()..sort();
    return set;
  }

  /// Applica i filtri correnti alla lista totale dei ragazzi
  List<_RagazzoData> get _ragazziFiltrati {
    final query = _searchCtrl.text.toLowerCase().trim();
    return _tuttiRagazzi.where((r) {
      // 1. Filtro Testuale (Nome o Squadriglia)
      final matchText = query.isEmpty ||
          r.nome.toLowerCase().contains(query) ||
          r.squadriglia.toLowerCase().contains(query);

      // 2. Filtro Squadriglia (Dropdown)
      final matchSquadriglia = _squadrigliaFiltro == null ||
          r.squadriglia.toLowerCase() == _squadrigliaFiltro!.toLowerCase();

      // 3. Filtro Alert Medici (Switch)
      final matchAlert = !_alertFiltro || r.hasAlert;

      return matchText && matchSquadriglia && matchAlert;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Re-renderizza la vista ad ogni digitazione nella ricerca
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
      currentIndex: 1, // Icona ragazzi selezionata nella BottomBar
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              // Padding top di 170 per lasciare spazio alla TopBar flottante
              padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BARRA DI RICERCA CENTRALIZZATA
                  JambSearchBar(
                    controller: _searchCtrl,
                    hintText: "Cerca scout o squadriglia...",
                  ),
                  const SizedBox(height: 16),

                  // SEZIONE FILTRI
                  RagazziFilters(
                    squadrigliaSelezionata: _squadrigliaFiltro,
                    alertMediciAttivo: _alertFiltro,
                    squadriglie: _squadriglie,
                    onSquadrigliaChanged: (sq) => setState(() => _squadrigliaFiltro = sq),
                    onAlertChanged: (v) => setState(() => _alertFiltro = v),
                  ),
                  const SizedBox(height: 24),

                  // LISTA RISULTATI
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

  /// Messaggio visualizzato quando la ricerca non produce risultati
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Nessun ragazzo trovato",
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Prova a cambiare i filtri o la ricerca",
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
