/// Mappa i valori di `ruolo_enum` (DB) alle etichette leggibili nella UI.
const Map<String, String> ruoloEnumToLabel = {
  'RAGAZZO': 'Squadrigliere',
  'VICE_CAPO_SQ': 'Vice Capo',
  'CAPO_SQ': 'Capo Squadriglia',
  'AIUTO_CAPO': 'Aiuto Capo',
  'CAPO_UNITA': 'Capo Unità',
  'CAPO_GRUPPO': 'Capo Gruppo',
};

/// Restituisce l'etichetta leggibile per un valore enum del ruolo.
/// Se il valore non è mappato, restituisce il valore stesso.
String ruoloLabel(String enumValue) => ruoloEnumToLabel[enumValue] ?? enumValue;
