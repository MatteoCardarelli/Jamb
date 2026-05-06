enum TappaSentiero {
    nulla,
    scoperta,
    competenza,
    responsabilita,
}

enum SpecialitaNome {
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
}

enum BrevettoNome{
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
}

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
            tipo: TappaSentiero.values.byName(map['tipo']),
            impegni: List<Impegno>.from(
                (map['impegni'] as List).map((x) => Impegno.fromMap(x)),
            ),
        );
    }
}

class Specialita {
    final SpecialitaNome nome; 
    final bool isPosseduta;
    final List<String>? prove;
    final DateTime? dataConseguimento;

    const Specialita({
        required this.nome,
        this.isPosseduta = false,
        this.prove,
        this.dataConseguimento,
    });

    Specialita copyWith({
        SpecialitaNome? nome,
        bool? isPosseduta,
        List<String>? prove,
        DateTime? dataConseguimento,
    }){
        return Specialita(
            nome: nome ?? this.nome,
            isPosseduta: isPosseduta ?? this.isPosseduta,
            prove: prove ?? this.prove,
            dataConseguimento: dataConseguimento ?? this.dataConseguimento,
        );
    }

    Map<String, dynamic> toMap() {
        return {
            'nome': nome.name,
            'isPosseduta': isPosseduta,
            'prove': prove,
            'dataConseguimento': dataConseguimento?.toIso8601String(),
        };
    }

    factory Specialita.fromMap(Map<String, dynamic> map) {
        return Specialita(
            nome: SpecialitaNome.values.byName(map['nome']),
            isPosseduta: map['isPosseduta'] ?? false,
            prove: map['prove'] != null ? List<String>.from(map['prove']) : null,
            dataConseguimento: map['dataConseguimento'] != null 
                ? DateTime.parse(map['dataConseguimento']) 
                : null,
        );
    }
}

class Brevetto {
    final BrevettoNome nome;
    final List<SpecialitaNome> specialitaCollegate;
    final bool isPosseduto;
    final DateTime? dataConseguimento;

    const Brevetto({
        required this.nome,
        required this.specialitaCollegate,
        this.isPosseduto = false,
        this.dataConseguimento,
    });

    Brevetto copyWith({
        BrevettoNome? nome,
        List<SpecialitaNome>? specialitaCollegate,
        bool? isPosseduto,
        DateTime? dataConseguimento,
    }){
        return Brevetto(
            nome: nome ?? this.nome,
            specialitaCollegate: specialitaCollegate ?? this.specialitaCollegate,
            isPosseduto: isPosseduto ?? this.isPosseduto,
            dataConseguimento: dataConseguimento ?? this.dataConseguimento,
        );
    }

    Map<String, dynamic> toMap() {
        return {
            'nome': nome.name,
            'specialitaCollegate': specialitaCollegate.map((e) => e.name).toList(),
            'isPosseduto': isPosseduto,
            'dataConseguimento': dataConseguimento?.toIso8601String(),
        };
    }

    factory Brevetto.fromMap(Map<String, dynamic> map) {
        return Brevetto(
            nome: BrevettoNome.values.byName(map['nome']),
            specialitaCollegate: List<SpecialitaNome>.from(
                (map['specialitaCollegate'] as List).map((e) => SpecialitaNome.values.byName(e))
            ),
            isPosseduto: map['isPosseduto'] ?? false,
            dataConseguimento: map['dataConseguimento'] != null 
                ? DateTime.parse(map['dataConseguimento']) 
                : null,
        );
    }
}

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
            tappaAttuale: Tappa.fromMap(map['tappaAttuale']),
            specialita: List<Specialita>.from(
                (map['specialita'] as List).map((x) => Specialita.fromMap(x)),
            ),
            brevetti: List<Brevetto>.from(
                (map['brevetti'] as List).map((x) => Brevetto.fromMap(x)),
            ),
        );
    }
}
