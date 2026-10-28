import 'package:flutter/material.dart';
import 'package:jamb/domain/errori/jamb_exception.dart';

/// Esegue un'[azione] di scrittura avviata dall'utente e, se fallisce,
/// mostra il motivo in uno SnackBar.
///
/// Restituisce `true` se l'azione è andata a buon fine, così la View può
/// decidere se chiudere la schermata o restare dov'è.
Future<bool> eseguiConFeedback(
  BuildContext context,
  Future<void> Function() azione,
) async {
  // Il messenger va letto prima dell'attesa: dopo, il context potrebbe
  // non essere più valido (es. schermata chiusa).
  final messenger = ScaffoldMessenger.of(context);
  try {
    await azione();
    return true;
  } catch (e, stackTrace) {
    debugPrint('Operazione fallita: $e\n$stackTrace');
    messenger.showSnackBar(
      SnackBar(
        content: Text(JambException.messaggioPer(e)),
        backgroundColor: const Color(0xFFB91C1C),
      ),
    );
    return false;
  }
}
