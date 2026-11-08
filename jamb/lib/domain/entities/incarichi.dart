/// Persona del gruppo, tra cui il Capo Gruppo sceglie l'Assistente Ecclesiastico.
class PersonaGruppo {
  final String id;
  final String nome;

  const PersonaGruppo({required this.id, required this.nome});
}

/// Persone di [persone] che non hanno già l'incarico, in ordine alfabetico.
List<PersonaGruppo> candidatiAssistente(
  Iterable<PersonaGruppo> persone,
  Iterable<PersonaGruppo> assistenti,
) {
  final gia = {for (final a in assistenti) a.id};
  return persone.where((p) => !gia.contains(p.id)).toList()
    ..sort((a, b) => a.nome.compareTo(b.nome));
}
