/// Anno scout di [data], es. "2026-2027": inizia il 1° settembre e finisce
/// il 31 agosto, come `memberships.anno_scout`.
String annoScoutDi(DateTime data) {
  final inizio = data.month >= 9 ? data.year : data.year - 1;
  return '$inizio-${inizio + 1}';
}
