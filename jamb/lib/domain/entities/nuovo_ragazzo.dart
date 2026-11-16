/// Ruoli che un ragazzo può avere in squadriglia, come valori di `ruolo_enum`,
/// nell'ordine in cui si propongono.
const List<String> ruoliRagazzo = ['CAPO_SQ', 'VICE_CAPO_SQ', 'RAGAZZO'];

/// Dati per aggiungere un ragazzo all'unità attiva. La scheda nasce senza
/// account: l'app per i ragazzi è facoltativa (decisione del 2026-11-09).
class NuovoRagazzo {
  final String nome;
  final String cognome;
  final DateTime? dataNascita;

  /// Nome della squadriglia (o sestiglia); `null` se l'unità non ne ha o
  /// non è ancora stata scelta.
  final String? squadriglia;

  /// Uno tra [ruoliRagazzo].
  final String ruolo;

  const NuovoRagazzo({
    required this.nome,
    required this.cognome,
    this.dataNascita,
    this.squadriglia,
    this.ruolo = 'RAGAZZO',
  });
}
