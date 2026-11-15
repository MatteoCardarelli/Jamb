// Crea su un progetto Supabase un gruppo di prova con unità, squadriglie e
// utenti, così da poter provare l'app da zero.
//
// Serve la chiave service_role, che scavalca le RLS: va passata solo
// nell'ambiente, mai scritta in un file. Da jamb/:
//
//   SUPABASE_URL=https://<ref>.supabase.co \
//   SUPABASE_SERVICE_ROLE_KEY=... \
//   JAMB_PASSWORD_PROVA=... \
//   JAMB_CONFERMA_PROGETTO=<ref> \
//   dart run tool/crea_dati_prova.dart
//
// Si può rilanciare: ciò che esiste già viene riusato.
import 'dart:io';

import 'package:jamb/domain/entities/anno_scout.dart';

import 'supabase_admin.dart';

const String _nomeGruppo = 'Gruppo di prova';

/// Un utente di prova, con il ruolo nell'unità di branca [branca].
class _UtenteProva {
  final String email;
  final String nome;
  final String cognome;
  final String branca;
  final String ruolo;
  final String? squadriglia;

  const _UtenteProva(
    this.email,
    this.nome,
    this.cognome,
    this.branca,
    this.ruolo, [
    this.squadriglia,
  ]);
}

const Map<String, String> _unita = {
  'COCA': 'Comunità Capi di prova',
  'LC': 'Branco di prova',
  'EG': 'Reparto di prova',
  'RS': 'Clan di prova',
};

const List<String> _squadriglie = ['Aquile', 'Volpi'];

const List<_UtenteProva> _utenti = [
  _UtenteProva(
    'prova.capogruppo@test.it',
    'Carla',
    'Gruppo',
    'COCA',
    'CAPO_GRUPPO',
  ),
  _UtenteProva('prova.capolc@test.it', 'Luca', 'Branco', 'LC', 'CAPO_UNITA'),
  _UtenteProva('prova.capoeg@test.it', 'Elena', 'Reparto', 'EG', 'CAPO_UNITA'),
  _UtenteProva('prova.aiutoeg@test.it', 'Marco', 'Aiuto', 'EG', 'AIUTO_CAPO'),
  _UtenteProva('prova.capors@test.it', 'Rita', 'Clan', 'RS', 'CAPO_UNITA'),
  _UtenteProva(
    'prova.caposq@test.it',
    'Sara',
    'Aquile',
    'EG',
    'CAPO_SQ',
    'Aquile',
  ),
  _UtenteProva(
    'prova.ragazzo1@test.it',
    'Paolo',
    'Aquile',
    'EG',
    'RAGAZZO',
    'Aquile',
  ),
  _UtenteProva(
    'prova.ragazzo2@test.it',
    'Giulia',
    'Volpi',
    'EG',
    'RAGAZZO',
    'Volpi',
  ),
];

Future<void> main() async {
  final db = SupabaseAdmin.daAmbiente();
  final password = variabileRichiesta('JAMB_PASSWORD_PROVA');
  try {
    final oggi = DateTime.now();
    final gruppoId = await db.trovaOCrea(
      'groups',
      {'nome': _nomeGruppo},
      {'zona': 'Prova'},
    );

    final unitaIds = <String, String>{};
    for (final voce in _unita.entries) {
      unitaIds[voce.key] = await db.trovaOCrea(
        'units',
        {'group_id': gruppoId, 'tipo_branca': voce.key},
        {'nome': voce.value},
      );
    }

    final squadriglieIds = <String, String>{};
    for (final nome in _squadriglie) {
      squadriglieIds[nome] = await db.trovaOCrea('squads', {
        'unit_id': unitaIds['EG']!,
        'nome': nome,
      });
    }

    for (final u in _utenti) {
      final utenteId = await db.creaUtente(
        email: u.email,
        nome: u.nome,
        cognome: u.cognome,
        gruppoId: gruppoId,
        password: password,
      );
      await db.trovaOCrea(
        'memberships',
        {'user_id': utenteId, 'unit_id': unitaIds[u.branca]!},
        {
          'ruolo': u.ruolo,
          'squad_id': u.squadriglia == null
              ? null
              : squadriglieIds[u.squadriglia],
          'anno_scout': annoScoutDi(oggi),
          'data_inizio': oggi.toIso8601String().split('T').first,
        },
      );
      stdout.writeln('${u.email}: ${u.ruolo} in ${u.branca}');
    }
    stdout.writeln('Dati di prova pronti nel gruppo "$_nomeGruppo".');
  } finally {
    db.chiudi();
  }
}
