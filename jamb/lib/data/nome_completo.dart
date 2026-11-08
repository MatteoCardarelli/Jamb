/// Nome e cognome da una riga di `users` (o da un suo incorporamento);
/// «Senza nome» se mancano entrambi.
String nomeCompletoDa(Object? utente) {
  final u = utente is Map ? utente : const {};
  final nome = [u['nome'], u['cognome']]
      .whereType<String>()
      .where((e) => e.trim().isNotEmpty)
      .join(' ');
  return nome.isEmpty ? 'Senza nome' : nome;
}
