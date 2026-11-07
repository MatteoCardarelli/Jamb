import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';

/// Apre un file archiviato con l'app adatta del telefono (lettore PDF,
/// galleria, editor), a partire dall'URL temporaneo restituito da
/// [ottieniUrl]. Un errore, nell'ottenere l'URL o nell'aprirlo, compare in
/// uno SnackBar.
Future<void> apriFile(BuildContext context, Future<String> Function() ottieniUrl) async {
  final messenger = ScaffoldMessenger.of(context);
  String? url;
  final ottenuto = await eseguiConFeedback(context, () async {
    url = await ottieniUrl();
  });
  if (!ottenuto) return;

  final aperto = await launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
  if (!aperto) {
    messenger.showSnackBar(const SnackBar(
      content: Text('Nessuna app del telefono può aprire questo file.'),
    ));
  }
}
