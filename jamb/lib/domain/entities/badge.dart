/// Un periodo di servizio o di appartenenza in un'unità.
class IncaricoStorico {
  /// Valore di `ruolo_enum`.
  final String ruolo;
  final String annoScout;

  /// Valore di `tipo_branca_enum` (`null` se sconosciuto).
  final String? tipoBranca;

  const IncaricoStorico({required this.ruolo, required this.annoScout, this.tipoBranca});
}

/// Categoria di un badge, che ne determina l'icona.
enum TipoBadge { anniDiServizio, capoUnita, capoGruppo, branche }

/// Riconoscimento virtuale ricavato dallo storico associativo (US2).
class BadgeJamb {
  final TipoBadge tipo;
  final String titolo;

  const BadgeJamb({required this.tipo, required this.titolo});
}

/// Ruoli da adulto, gli unici che contano come anni di servizio.
const Set<String> _ruoliDaCapo = {'AIUTO_CAPO', 'CAPO_UNITA', 'CAPO_GRUPPO'};

/// Soglie degli anni di servizio, dalla più alta.
const List<int> _soglieAnni = [10, 5, 3, 1];

/// Badge ricavati dallo [storico], senza dati memorizzati a parte: un badge
/// per la soglia più alta di anni di servizio, uno per ogni incarico di
/// responsabilità ricoperto e uno se si è servito in più branche.
List<BadgeJamb> badgeDaStorico(Iterable<IncaricoStorico> storico) {
  final daCapo = storico.where((i) => _ruoliDaCapo.contains(i.ruolo)).toList();
  final anni = {for (final i in daCapo) i.annoScout}.length;
  final branche = {
    for (final i in daCapo)
      if (i.tipoBranca != null && i.tipoBranca != 'COCA') i.tipoBranca,
  }.length;

  return [
    for (final soglia in _soglieAnni.where((s) => anni >= s).take(1))
      BadgeJamb(
        tipo: TipoBadge.anniDiServizio,
        titolo: soglia == 1 ? '1 anno di servizio' : '$soglia anni di servizio',
      ),
    if (daCapo.any((i) => i.ruolo == 'CAPO_UNITA'))
      const BadgeJamb(tipo: TipoBadge.capoUnita, titolo: 'Capo Unità'),
    if (daCapo.any((i) => i.ruolo == 'CAPO_GRUPPO'))
      const BadgeJamb(tipo: TipoBadge.capoGruppo, titolo: 'Capo Gruppo'),
    if (branche >= 2)
      BadgeJamb(tipo: TipoBadge.branche, titolo: 'Servizio in $branche branche'),
  ];
}
