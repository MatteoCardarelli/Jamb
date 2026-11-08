import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jamb/core/session_service.dart';
import '../../domain/repositories/preferenze_repository.dart';

/// Preferenze salvate sul dispositivo, per utente: sullo stesso telefono
/// possono accedere capi diversi.
class LocalePreferenzeRepository implements IPreferenzeRepository {
  final SessionService _session;
  LocalePreferenzeRepository(this._session);

  String _chiave(String nome) => 'preferenza_${nome}_${_session.userId}';

  @override
  Future<Preferenze> leggi() async {
    try {
      final p = await SharedPreferences.getInstance();
      return Preferenze(
        mostraPillole: p.getBool(_chiave('pillole')) ?? true,
        mostraCassa: p.getBool(_chiave('cassa')) ?? true,
      );
    } catch (e) {
      // Perdere una preferenza non deve impedire di usare l'app.
      debugPrint('Preferenze non leggibili: $e');
      return const Preferenze();
    }
  }

  @override
  Future<void> salva(Preferenze preferenze) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_chiave('pillole'), preferenze.mostraPillole);
    await p.setBool(_chiave('cassa'), preferenze.mostraCassa);
  }
}
