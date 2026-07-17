import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamb/core/supabase_client.dart';

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

  /// Unità in cui l'utente sta operando (per ora la prima membership attiva).
  String? get activeUnitId => _activeUnitId;

  /// Tutte le membership attive dell'utente.
  List<SessionMembership> get memberships => _memberships;

  /// Nome e cognome concatenati dell'utente loggato.
  String get nomeCompleto =>
      [_nome, _cognome].where((e) => e != null && e.trim().isNotEmpty).join(' ');

  /// Ruolo dell'utente nell'unità attiva (`null` se non determinabile).
  String? get activeRole {
    for (final m in _memberships) {
      if (m.unitId == _activeUnitId) return m.ruolo;
    }
    return null;
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

      final rows = await supabase
          .from('memberships')
          .select('unit_id, squad_id, ruolo')
          .eq('user_id', user.id)
          .eq('is_active', true);

      _userId = user.id;
      _nome = profilo?['nome'] as String?;
      _cognome = profilo?['cognome'] as String?;
      _groupId = profilo?['group_id'] as String?;
      _memberships = (rows as List)
          .map((r) => SessionMembership(
                unitId: r['unit_id'] as String,
                squadId: r['squad_id'] as String?,
                ruolo: r['ruolo'] as String,
              ))
          .toList();

      if (_memberships.isEmpty) {
        _activeUnitId = null;
        _status = SessionStatus.noMembership;
      } else {
        // Sessione minima: l'unità attiva è la prima membership.
        _activeUnitId = _memberships.first.unitId;
        _status = SessionStatus.ready;
      }
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
