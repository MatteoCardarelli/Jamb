import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamb/core/permessi.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/core/unita_attiva.dart';

/// Stati possibili della sessione applicativa.
enum SessionStatus { loading, unauthenticated, noMembership, ready, error }

/// Una membership attiva dell'utente: il suo ruolo in una specifica unità.
class SessionMembership {
  final String unitId;
  final String? squadId;
  final String ruolo;

  const SessionMembership({
    required this.unitId,
    this.squadId,
    required this.ruolo,
  });
}

/// Sessione di dominio: chi è l'utente, che ruolo ha e in quale unità opera.
///
/// Vive in cima all'albero dei widget (Provider) e viene letta da repository
/// e UI. Si sottoscrive ai cambi di autenticazione di Supabase: al login
/// carica profilo e membership, al logout azzera tutto.
class SessionService extends ChangeNotifier {
  SessionStatus _status = SessionStatus.loading;
  String? _userId;
  String? _nome;
  String? _cognome;
  String? _groupId;
  List<SessionMembership> _memberships = const [];
  List<UnitaDisponibile> _unita = const [];
  String? _activeUnitId;

  StreamSubscription<AuthState>? _authSub;

  /// Imposta lo stato iniziale e si mette in ascolto dei cambi di autenticazione.
  SessionService() {
    // Stato iniziale per evitare un flash prima del primo evento auth.
    _status = supabase.auth.currentSession != null
        ? SessionStatus.loading
        : SessionStatus.unauthenticated;

    // Il primo evento emesso è initialSession (sessione già presente all'avvio).
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.initialSession:
          if (data.session != null) {
            load();
          } else {
            _clear();
          }
          break;
        case AuthChangeEvent.signedOut:
          _clear();
          break;
        default:
          break; // tokenRefreshed, userUpdated, ecc.: ignorati
      }
    });
  }

  /// Stato corrente della sessione.
  SessionStatus get status => _status;

  /// UUID dell'utente loggato (`null` se non autenticato).
  String? get userId => _userId;

  /// Gruppo scout dell'utente.
  String? get groupId => _groupId;

  /// Unità in cui l'utente sta operando: scelta dal selettore nel menu del
  /// profilo e ricordata sul dispositivo (vedi [impostaUnitaAttiva]).
  String? get activeUnitId => _activeUnitId;

  /// Unità tra cui l'utente può scegliere, in ordine alfabetico: quelle delle
  /// sue membership e, per il Capo Gruppo, tutte quelle del gruppo.
  List<UnitaDisponibile> get unitaDisponibili => _unita;

  /// Nome dell'unità attiva (vuoto se non determinabile).
  String get nomeUnitaAttiva {
    for (final u in _unita) {
      if (u.id == _activeUnitId) return u.nome;
    }
    return '';
  }

  /// Tutte le membership attive dell'utente.
  List<SessionMembership> get memberships => _memberships;

  /// Nome e cognome concatenati dell'utente loggato.
  String get nomeCompleto =>
      [_nome, _cognome].where((e) => e != null && e.trim().isNotEmpty).join(' ');

  bool get _capoGruppo => _memberships.any((m) => m.ruolo == 'CAPO_GRUPPO');

  /// Ruolo dell'utente nell'unità attiva: quello della membership, oppure
  /// `CAPO_GRUPPO` in un'unità del gruppo di cui non è membro.
  String? get activeRole {
    for (final m in _memberships) {
      if (m.unitId == _activeUnitId) return m.ruolo;
    }
    return _capoGruppo && _activeUnitId != null ? 'CAPO_GRUPPO' : null;
  }

  /// Cosa l'utente può fare nell'unità attiva.
  Permessi get permessi => Permessi(ruolo: activeRole, capoGruppo: _capoGruppo);

  /// Chiave della preferenza con l'ultima unità scelta, per utente: sullo
  /// stesso dispositivo possono accedere capi diversi.
  static String _chiaveUnita(String userId) => 'unita_attiva_$userId';

  /// Rende attiva l'unità [unitId] e la ricorda per il prossimo accesso.
  /// Un'unità non disponibile è ignorata. L'app ricrea repository e
  /// ViewModel, così nessun dato dell'unità precedente resta in memoria.
  Future<void> impostaUnitaAttiva(String unitId) async {
    if (unitId == _activeUnitId || !_unita.any((u) => u.id == unitId)) return;
    _activeUnitId = unitId;
    notifyListeners();
    try {
      final preferenze = await SharedPreferences.getInstance();
      await preferenze.setString(_chiaveUnita(_userId!), unitId);
    } catch (e) {
      // Non ricordarla costa solo una scelta in più al prossimo accesso.
      debugPrint('Unità attiva non salvata: $e');
    }
  }

  /// Ultima unità scelta dall'utente su questo dispositivo, se c'è.
  Future<String?> _unitaSalvata(String userId) async {
    try {
      final preferenze = await SharedPreferences.getInstance();
      return preferenze.getString(_chiaveUnita(userId));
    } catch (e) {
      debugPrint('Unità salvata non leggibile: $e');
      return null;
    }
  }

  /// Carica profilo (`users`) e membership attive dell'utente loggato,
  /// impostando lo `status` di conseguenza (ready / noMembership / error).
  Future<void> load() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _clear();
      return;
    }

    _status = SessionStatus.loading;
    notifyListeners();

    try {
      final profilo = await supabase
          .from('users')
          .select('nome, cognome, group_id')
          .eq('id', user.id)
          .maybeSingle();

      final List<dynamic> rows = await supabase
          .from('memberships')
          .select('unit_id, squad_id, ruolo, units ( nome )')
          .eq('user_id', user.id)
          .eq('is_active', true);

      _userId = user.id;
      _nome = profilo?['nome'] as String?;
      _cognome = profilo?['cognome'] as String?;
      _groupId = profilo?['group_id'] as String?;
      _memberships = rows
          .map((r) => SessionMembership(
                unitId: r['unit_id'] as String,
                squadId: r['squad_id'] as String?,
                ruolo: r['ruolo'] as String,
              ))
          .toList();

      // Il Capo Gruppo può operare in tutte le unità del gruppo.
      var delGruppo = <UnitaDisponibile>[];
      if (_capoGruppo && _groupId != null) {
        final List<dynamic> unita = await supabase
            .from('units')
            .select('id, nome')
            .eq('group_id', _groupId!)
            // La Co.Ca. non è un'unità in cui operare: ha solo un drive condiviso.
            .neq('tipo_branca', 'COCA');
        delGruppo = [
          for (final u in unita)
            UnitaDisponibile(id: u['id'] as String, nome: (u['nome'] ?? '') as String),
        ];
      }
      _unita = componiUnitaDisponibili(
        daMembership: [
          for (final r in rows)
            UnitaDisponibile(
              id: r['unit_id'] as String,
              nome: ((r['units'] as Map?)?['nome'] ?? '') as String,
              ruolo: r['ruolo'] as String,
            ),
        ],
        delGruppo: delGruppo,
      );

      _activeUnitId = scegliUnitaIniziale(_unita, await _unitaSalvata(user.id));
      _status = _activeUnitId == null
          ? SessionStatus.noMembership
          : SessionStatus.ready;
    } catch (e) {
      debugPrint('Errore caricamento sessione: $e');
      _status = SessionStatus.error;
    }
    notifyListeners();
  }

  /// Effettua il logout; l'azzeramento avviene nel listener su `signedOut`.
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  /// Azzera i dati di sessione e riporta lo stato a non autenticato.
  void _clear() {
    _userId = null;
    _nome = null;
    _cognome = null;
    _groupId = null;
    _memberships = const [];
    _unita = const [];
    _activeUnitId = null;
    _status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
