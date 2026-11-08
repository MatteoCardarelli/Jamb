/// Anno scout di [data], es. "2026-2027": inizia il 1° settembre e finisce
/// il 31 agosto, come `memberships.anno_scout`.
String annoScoutDi(DateTime data) {
  final inizio = data.month >= 9 ? data.year : data.year - 1;
  return '$inizio-${inizio + 1}';
}

/// Ultimo giorno (31 agosto) dell'anno scout di [data]: la fine proposta
/// per un evento che si ripete.
DateTime fineAnnoScout(DateTime data) =>
    DateTime(data.month >= 9 ? data.year + 1 : data.year, 8, 31);
