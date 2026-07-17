/// Tappe del Sentiero (la progressione personale dello scout).
enum TappaSentiero {
    nulla,
    scoperta,
    competenza,
    responsabilita;

    static TappaSentiero safeByName(String name) {
      try {
        return TappaSentiero.values.byName(name);
      } catch (_) {
        return TappaSentiero.nulla;
      }
    }
}

/// Nomi delle specialità conquistabili da uno scout (catalogo AGESCI).
enum SpecialitaNome {
    Aereomodellista,
    Allevatore,
    Alpinista,
    AmicoDegliAnimali,
    AmicoDelQuartiere,
    Archeologo,
    Artigiano,
    ArtistaDiStrada,
    Astronomo,
    Atleta,
    Attore,
    Battelliere,
    Boscaiolo,
    Botanico,
    Campeggiatore,
    Canoista,
    Cantante,
    CarpentiereNavale,
    Ciclista,
    Collezionista,
    Coltivatore,
    Corrispondente,
    CorrispondenteRadio,
    Cuoco,
    Danzatore,
    Disegnatore,
    Elettricista,
    Elettronico,
    EspertoDelComputer,
    Europeista,
    Falegname,
    FaTutto,
    Folclorista,
    Fotografo,
    Giardiniere,
    Giocattolaio,
    Grafico,
    Guida,
    GuidaMarina,
    Hebertista,
    Idraulico,
    Infermiere,
    Interprete,
    LavoratoreInCuoio,
    MaestroDeiGiochi,
    MaestroDeiNodi,
    Meccanico,
    Modellista,
    Muratore,
    Musicista,
    Naturalista,
    Nuotatore,
    Osservatore,
    OsservatoreMeteo,
    Pescatore,
    Pompiere,
    Redattore,
    Regista,
    Sarto,
    Scenografo,
    Segnalatore,
    ServizioDellaParola,
    ServizioLiturgico,
    ServizioMissionario,
    Topografo,
    Velista;

    /// Converte un nome nell'enum in sicurezza (null se non riconosciuto).
    static SpecialitaNome? safeByName(String name) {
      try {
        return SpecialitaNome.values.byName(name);
      } catch (_) {
        return null;
      }
    }
}

/// Nomi dei brevetti di competenza conquistabili da uno scout.
enum BrevettoNome {
    Naturalista, 
    Artista, 
    Giornalista, 
    GraficoMultimediale, 
    CittadinoDelMondo, 
    Liturgista, 
    AnimatoreSportivo, 
    GuidaAlpina, 
    ManiAbili, 
    Pioniere, 
    Soccorritore, 
    Sherpa, 
    Trappeur, 
    MaestroDelleTecnologie, 
    EsploratoreDelleAcque;

    /// Converte un nome nell'enum in sicurezza (null se non riconosciuto).
    static BrevettoNome? safeByName(String name) {
      try {
        return BrevettoNome.values.byName(name);
      } catch (_) {
        return null;
      }
    }
}

/// Associa a ogni brevetto le specialità che concorrono a ottenerlo.
extension BrevettoNomeExtension on BrevettoNome {
  /// Ritorna la lista di specialità che concorrono all'ottenimento del brevetto
  List<SpecialitaNome> get specialitaCorrelate {
    switch (this) {
      case BrevettoNome.Naturalista:
        return [
          SpecialitaNome.Allevatore, SpecialitaNome.Alpinista, SpecialitaNome.AmicoDegliAnimali,
          SpecialitaNome.Astronomo, SpecialitaNome.Boscaiolo, SpecialitaNome.Botanico,
          SpecialitaNome.Campeggiatore, SpecialitaNome.Coltivatore, SpecialitaNome.Disegnatore,
          SpecialitaNome.Fotografo, SpecialitaNome.Giardiniere, SpecialitaNome.GuidaMarina,
          SpecialitaNome.Hebertista, SpecialitaNome.Naturalista, SpecialitaNome.Osservatore,
          SpecialitaNome.OsservatoreMeteo, SpecialitaNome.Pescatore, SpecialitaNome.Topografo,
        ];
      case BrevettoNome.Artista:
        return [
          SpecialitaNome.Attore, SpecialitaNome.Cantante, SpecialitaNome.Danzatore,
          SpecialitaNome.Disegnatore, SpecialitaNome.Elettricista, SpecialitaNome.Falegname,
          SpecialitaNome.FaTutto, SpecialitaNome.Fotografo, SpecialitaNome.MaestroDeiGiochi,
          SpecialitaNome.Musicista, SpecialitaNome.Redattore, SpecialitaNome.Sarto,
          SpecialitaNome.ServizioDellaParola, SpecialitaNome.ServizioLiturgico,
        ];
      case BrevettoNome.Giornalista:
        return [
          SpecialitaNome.AmicoDelQuartiere, SpecialitaNome.Corrispondente, SpecialitaNome.CorrispondenteRadio,
          SpecialitaNome.EspertoDelComputer, SpecialitaNome.Europeista, SpecialitaNome.Folclorista,
          SpecialitaNome.Fotografo, SpecialitaNome.Guida, SpecialitaNome.Interprete,
          SpecialitaNome.Osservatore, SpecialitaNome.Redattore,
        ];
      case BrevettoNome.GraficoMultimediale:
        return [
          SpecialitaNome.Artigiano, SpecialitaNome.Disegnatore, SpecialitaNome.Elettricista,
          SpecialitaNome.Elettronico, SpecialitaNome.EspertoDelComputer, SpecialitaNome.Europeista,
          SpecialitaNome.FaTutto, SpecialitaNome.Falegname, SpecialitaNome.Folclorista,
          SpecialitaNome.Fotografo, SpecialitaNome.Grafico, SpecialitaNome.LavoratoreInCuoio,
          SpecialitaNome.Osservatore, SpecialitaNome.Redattore, SpecialitaNome.Regista,
          SpecialitaNome.Sarto, SpecialitaNome.Scenografo,
        ];
      case BrevettoNome.CittadinoDelMondo:
        return [
          SpecialitaNome.Archeologo, SpecialitaNome.Attore, SpecialitaNome.Collezionista,
          SpecialitaNome.Corrispondente, SpecialitaNome.CorrispondenteRadio, SpecialitaNome.EspertoDelComputer,
          SpecialitaNome.Disegnatore, SpecialitaNome.Europeista, SpecialitaNome.Folclorista,
          SpecialitaNome.Fotografo, SpecialitaNome.Interprete, SpecialitaNome.MaestroDeiGiochi,
          SpecialitaNome.Musicista, SpecialitaNome.Osservatore, SpecialitaNome.Redattore,
          SpecialitaNome.ServizioMissionario,
        ];
      case BrevettoNome.Liturgista:
        return [
          SpecialitaNome.Attore, SpecialitaNome.Cantante, SpecialitaNome.Corrispondente,
          SpecialitaNome.Disegnatore, SpecialitaNome.Falegname, SpecialitaNome.Folclorista, 
          SpecialitaNome.Fotografo, SpecialitaNome.Interprete, SpecialitaNome.LavoratoreInCuoio,
          SpecialitaNome.Musicista, SpecialitaNome.Redattore, SpecialitaNome.Sarto,
          SpecialitaNome.ServizioDellaParola, SpecialitaNome.ServizioLiturgico, SpecialitaNome.ServizioMissionario,
        ];
      case BrevettoNome.AnimatoreSportivo:
        return [
          SpecialitaNome.Alpinista, SpecialitaNome.Atleta, SpecialitaNome.Ciclista,
          SpecialitaNome.Hebertista, SpecialitaNome.Infermiere, SpecialitaNome.MaestroDeiGiochi,
          SpecialitaNome.Nuotatore,
        ];
      case BrevettoNome.GuidaAlpina:
        return [
          SpecialitaNome.Alpinista, SpecialitaNome.AmicoDegliAnimali, SpecialitaNome.Astronomo,
          SpecialitaNome.Botanico, SpecialitaNome.Fotografo, SpecialitaNome.Guida, 
          SpecialitaNome.Hebertista, SpecialitaNome.Infermiere, SpecialitaNome.Naturalista, 
          SpecialitaNome.Nuotatore, SpecialitaNome.Osservatore, SpecialitaNome.OsservatoreMeteo, 
          SpecialitaNome.Pompiere, SpecialitaNome.Segnalatore, SpecialitaNome.Topografo,
        ];
      case BrevettoNome.ManiAbili:
        return [
          SpecialitaNome.Aereomodellista, SpecialitaNome.Boscaiolo, SpecialitaNome.Campeggiatore, 
          SpecialitaNome.CarpentiereNavale, SpecialitaNome.Disegnatore, SpecialitaNome.Elettricista,
          SpecialitaNome.Falegname, SpecialitaNome.FaTutto, SpecialitaNome.Giocattolaio,
          SpecialitaNome.LavoratoreInCuoio, SpecialitaNome.MaestroDeiNodi, SpecialitaNome.Meccanico, 
          SpecialitaNome.Modellista, SpecialitaNome.Muratore, SpecialitaNome.Sarto,
        ];
      case BrevettoNome.Pioniere:
        return [
          SpecialitaNome.Boscaiolo, SpecialitaNome.Campeggiatore, SpecialitaNome.CarpentiereNavale,
          SpecialitaNome.Disegnatore, SpecialitaNome.Falegname, SpecialitaNome.FaTutto, 
          SpecialitaNome.Hebertista, SpecialitaNome.Infermiere, SpecialitaNome.LavoratoreInCuoio, 
          SpecialitaNome.MaestroDeiNodi, SpecialitaNome.Nuotatore, SpecialitaNome.Osservatore, 
          SpecialitaNome.OsservatoreMeteo, SpecialitaNome.Pompiere, SpecialitaNome.Sarto, 
          SpecialitaNome.Topografo,
        ];
      case BrevettoNome.Soccorritore:
        return [
          SpecialitaNome.Alpinista, SpecialitaNome.Botanico, SpecialitaNome.Campeggiatore,
          SpecialitaNome.CorrispondenteRadio, SpecialitaNome.FaTutto, SpecialitaNome.Hebertista,
          SpecialitaNome.Infermiere, SpecialitaNome.Naturalista, SpecialitaNome.Nuotatore, 
          SpecialitaNome.Pompiere, SpecialitaNome.Segnalatore, SpecialitaNome.Topografo,
        ];
      case BrevettoNome.Sherpa:
        return [
          SpecialitaNome.Alpinista, SpecialitaNome.AmicoDegliAnimali, SpecialitaNome.Astronomo,
          SpecialitaNome.Boscaiolo, SpecialitaNome.Botanico, SpecialitaNome.Campeggiatore,
          SpecialitaNome.Ciclista, SpecialitaNome.GuidaMarina, SpecialitaNome.Hebertista, 
          SpecialitaNome.Infermiere, SpecialitaNome.Naturalista, SpecialitaNome.Nuotatore, 
          SpecialitaNome.Osservatore, SpecialitaNome.OsservatoreMeteo, SpecialitaNome.Segnalatore, 
          SpecialitaNome.Topografo,
        ];
      case BrevettoNome.Trappeur:
        return [
          SpecialitaNome.Astronomo, SpecialitaNome.Battelliere, SpecialitaNome.Boscaiolo,
          SpecialitaNome.Botanico, SpecialitaNome.Campeggiatore, SpecialitaNome.Falegname, 
          SpecialitaNome.FaTutto, SpecialitaNome.Hebertista, SpecialitaNome.Infermiere, 
          SpecialitaNome.LavoratoreInCuoio, SpecialitaNome.Naturalista, SpecialitaNome.Nuotatore, 
          SpecialitaNome.Osservatore, SpecialitaNome.OsservatoreMeteo, SpecialitaNome.Pescatore, 
          SpecialitaNome.Pompiere, SpecialitaNome.Sarto, SpecialitaNome.Segnalatore,
        ];
      case BrevettoNome.MaestroDelleTecnologie:
        return [
          SpecialitaNome.EspertoDelComputer, SpecialitaNome.Elettronico, SpecialitaNome.Meccanico, 
          SpecialitaNome.Grafico, SpecialitaNome.Fotografo, SpecialitaNome.Elettricista,
        ];
      case BrevettoNome.EsploratoreDelleAcque:
        return [
          SpecialitaNome.Nuotatore, SpecialitaNome.Canoista, SpecialitaNome.Pescatore,
          SpecialitaNome.Battelliere, SpecialitaNome.GuidaMarina, SpecialitaNome.CarpentiereNavale,
          SpecialitaNome.Velista, SpecialitaNome.Modellista,
        ];
    }
  }
}

/// Singolo impegno/prova, con testo e stato di completamento.
class Impegno {
    final String titolo;
    final bool isCompletato;

    const Impegno({
        required this.titolo,
        this.isCompletato = false,
    });

    Impegno copyWith({
        String? titolo,
        bool? isCompletato,
    }){
        return Impegno(
            titolo: titolo ?? this.titolo,
            isCompletato: isCompletato ?? this.isCompletato,
        );
    }

    Map<String, dynamic> toMap() {
        return {
            'titolo': titolo,
            'isCompletato': isCompletato,
        };
    }

    factory Impegno.fromMap(Map<String, dynamic> map) {
        return Impegno(
            titolo: map['titolo'] ?? '',
            isCompletato: map['isCompletato'] ?? false,
        );
    }
}

/// Tappa del Sentiero raggiunta, con i relativi impegni.
class Tappa {
    final TappaSentiero tipo;
    final List<Impegno> impegni;

    const Tappa({
        required this.tipo,
        required this.impegni,
    });

    Tappa copyWith({
        TappaSentiero? tipo,
        List<Impegno>? impegni,
    }){
        return Tappa(
            tipo: tipo ?? this.tipo,
            impegni: impegni ?? this.impegni,
        );
    }

    Map<String, dynamic> toMap() {
        return {
            'tipo': tipo.name,
            'impegni': impegni.map((x) => x.toMap()).toList(),
        };
    }

    factory Tappa.fromMap(Map<String, dynamic> map) {
        return Tappa(
            tipo: TappaSentiero.safeByName(map['tipo'] ?? ''),
            impegni: map['impegni'] != null 
                ? List<Impegno>.from((map['impegni'] as List).map((x) => Impegno.fromMap(x)))
                : const [],
        );
    }
}

/// Specialità dello scout, con le sue prove ed eventuale data di conseguimento.
class Specialita {
  final SpecialitaNome nome;
  final List<Impegno> prove;
  final DateTime? dataConseguimento;

  const Specialita({
    required this.nome,
    this.prove = const [],
    this.dataConseguimento,
  });

  /// Indica se la specialità è stata interamente completata e assegnata
  bool get isPosseduta => prove.isNotEmpty && prove.every((p) => p.isCompletato) && dataConseguimento != null;

  Specialita copyWith({
    SpecialitaNome? nome,
    List<Impegno>? prove,
    DateTime? dataConseguimento,
  }) {
    return Specialita(
      nome: nome ?? this.nome,
      prove: prove ?? this.prove,
      dataConseguimento: dataConseguimento ?? this.dataConseguimento,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome.name,
      'prove': prove.map((x) => x.toMap()).toList(),
      'dataConseguimento': dataConseguimento?.toIso8601String(),
    };
  }

  /// Metodo statico per caricare in sicurezza ignorando nomi obsoleti
  static Specialita? fromMap(Map<String, dynamic> map) {
    final nomeEnum = SpecialitaNome.safeByName(map['nome']);
    if (nomeEnum == null) return null;
    
    return Specialita(
      nome: nomeEnum,
      prove: map['prove'] != null
          ? List<Impegno>.from((map['prove'] as List).map((x) => Impegno.fromMap(x)))
          : const [],
      dataConseguimento: map['dataConseguimento'] != null ? DateTime.parse(map['dataConseguimento']) : null,
    );
  }
}

/// Brevetto di competenza dello scout, con specialità collegate e prova finale.
class Brevetto {
  final BrevettoNome nome;
  final List<SpecialitaNome> specialitaCollegate;
  final bool provaFinaleSuperata;
  final String? provaFinaleDescrizione;
  final DateTime? dataConseguimento;

  const Brevetto({
    required this.nome,
    required this.specialitaCollegate,
    this.provaFinaleSuperata = false,
    this.provaFinaleDescrizione,
    this.dataConseguimento,
  });

  bool get isPosseduto => provaFinaleSuperata && dataConseguimento != null;

  Brevetto copyWith({
    BrevettoNome? nome,
    List<SpecialitaNome>? specialitaCollegate,
    bool? provaFinaleSuperata,
    String? provaFinaleDescrizione,
    DateTime? dataConseguimento,
  }) {
    return Brevetto(
      nome: nome ?? this.nome,
      specialitaCollegate: specialitaCollegate ?? this.specialitaCollegate,
      provaFinaleSuperata: provaFinaleSuperata ?? this.provaFinaleSuperata,
      provaFinaleDescrizione: provaFinaleDescrizione ?? this.provaFinaleDescrizione,
      dataConseguimento: dataConseguimento ?? this.dataConseguimento,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome.name,
      'specialitaCollegate': specialitaCollegate.map((e) => e.name).toList(),
      'provaFinaleSuperata': provaFinaleSuperata,
      'provaFinaleDescrizione': provaFinaleDescrizione,
      'dataConseguimento': dataConseguimento?.toIso8601String(),
    };
  }

  /// Metodo statico per caricare in sicurezza ignorando nomi obsoleti
  static Brevetto? fromMap(Map<String, dynamic> map) {
    final nomeEnum = BrevettoNome.safeByName(map['nome']);
    if (nomeEnum == null) return null;

    return Brevetto(
      nome: nomeEnum,
      specialitaCollegate: List<SpecialitaNome>.from(
          (map['specialitaCollegate'] as List)
          .map((e) => SpecialitaNome.safeByName(e))
          .whereType<SpecialitaNome>()
      ),
      provaFinaleSuperata: map['provaFinaleSuperata'] ?? false,
      provaFinaleDescrizione: map['provaFinaleDescrizione'],
      dataConseguimento: map['dataConseguimento'] != null ? DateTime.parse(map['dataConseguimento']) : null,
    );
  }
}

/// Progressione complessiva di uno scout: tappa attuale, specialità e brevetti.
class ProgressoScout{
    final Tappa tappaAttuale;
    final List<Specialita> specialita;
    final List<Brevetto> brevetti;

    const ProgressoScout({
        this.tappaAttuale = const Tappa(tipo: TappaSentiero.nulla, impegni: []),
        this.specialita = const[],
        this.brevetti = const[],
    });

    ProgressoScout copyWith({
        Tappa? tappaAttuale,
        List<Specialita>? specialita,
        List<Brevetto>? brevetti,
    }){
        return ProgressoScout(
            tappaAttuale: tappaAttuale ?? this.tappaAttuale,
            specialita: specialita ?? this.specialita,
            brevetti: brevetti ?? this.brevetti,
        );
    }

    Map<String, dynamic> toMap() {
        return {
            'tappaAttuale': tappaAttuale.toMap(),
            'specialita': specialita.map((x) => x.toMap()).toList(),
            'brevetti': brevetti.map((x) => x.toMap()).toList(),
        };
    }

    factory ProgressoScout.fromMap(Map<String, dynamic> map) {
        return ProgressoScout(
            tappaAttuale: Tappa.fromMap(map['tappaAttuale'] ?? {}),
            specialita: List<Specialita>.from(
                (map['specialita'] as List? ?? [])
                .map((x) => Specialita.fromMap(x))
                .whereType<Specialita>(),
            ),
            brevetti: List<Brevetto>.from(
                (map['brevetti'] as List? ?? [])
                .map((x) => Brevetto.fromMap(x))
                .whereType<Brevetto>(),
            ),
        );
    }
}
