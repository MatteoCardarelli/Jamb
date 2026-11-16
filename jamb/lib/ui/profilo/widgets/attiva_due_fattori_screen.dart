import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jamb/domain/entities/secondo_fattore.dart';
import 'package:jamb/domain/repositories/auth_repository.dart';
import 'package:jamb/ui/auth/widgets/campo_codice.dart';
import 'package:jamb/ui/core/widgets/jamb_barra_azioni.dart';
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/ui/core/widgets/jamb_pulsante_secondario.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';
import 'package:jamb/ui/core/widgets/jamb_schermata_elenco.dart';
import 'package:jamb/ui/profilo/view_model/attiva_due_fattori_view_model.dart';

const _testo = TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.4);

/// Attivazione della verifica in due passaggi, in tre passi: installare
/// un'app di autenticazione, inquadrare il codice QR, scrivere il primo
/// codice.
class AttivaDueFattoriScreen extends StatelessWidget {
  const AttivaDueFattoriScreen({super.key});

  /// Apre l'attivazione; restituisce `true` se la verifica è stata attivata.
  static Future<bool?> apri(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AttivaDueFattoriScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AttivaDueFattoriViewModel(ctx.read<IAuthRepository>()),
      child: const _AttivaDueFattoriView(),
    );
  }
}

class _AttivaDueFattoriView extends StatefulWidget {
  const _AttivaDueFattoriView();

  @override
  State<_AttivaDueFattoriView> createState() => _AttivaDueFattoriViewState();
}

class _AttivaDueFattoriViewState extends State<_AttivaDueFattoriView> {
  final _codice = TextEditingController();
  bool _inCorso = false;

  @override
  void dispose() {
    _codice.dispose();
    super.dispose();
  }

  Future<void> _attiva(AttivaDueFattoriViewModel viewModel) async {
    setState(() => _inCorso = true);
    final fatto = await eseguiConFeedback(
      context,
      () => viewModel.conferma(_codice.text),
    );
    if (!mounted) return;
    setState(() => _inCorso = false);
    if (fatto) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttivaDueFattoriViewModel>();
    final attivazione = viewModel.attivazione;

    return JambSchermataElenco(
      titolo: 'Verifica in due passaggi',
      caricamento: viewModel.isLoading,
      errore: viewModel.errore,
      onRiprova: viewModel.prepara,
      children: [
        const JambRiquadro(
          titolo: '1. Scarica un\'app',
          children: [
            Text(
              'Sul telefono serve un\'app di autenticazione, per esempio '
              'Google Authenticator o Microsoft Authenticator. È gratuita e '
              'funziona anche senza rete.',
              style: _testo,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (attivazione != null) ...[
          _RiquadroQr(attivazione),
          const SizedBox(height: 16),
        ],
        JambRiquadro(
          titolo: '3. Scrivi il codice',
          children: [
            const Text(
              'L\'app mostra un codice di 6 cifre che cambia ogni 30 '
              'secondi: scrivi quello che vedi ora.',
              style: _testo,
            ),
            const SizedBox(height: 12),
            CampoCodice(
              controller: _codice,
              onSubmitted: (_) => _attiva(viewModel),
            ),
            const SizedBox(height: 16),
            JambBarraAzioni(
              mostraIndietro: false,
              etichetta: 'Attiva',
              icona: Icons.verified_user_outlined,
              onPressed: _inCorso || attivazione == null
                  ? null
                  : () => _attiva(viewModel),
            ),
          ],
        ),
      ],
    );
  }
}

/// Codice QR da inquadrare con l'app e, in alternativa, la chiave da
/// scrivere a mano.
class _RiquadroQr extends StatelessWidget {
  final AttivazioneSecondoFattore attivazione;

  const _RiquadroQr(this.attivazione);

  /// La chiave a gruppi di 4 caratteri, più facile da ricopiare.
  String get _chiaveLeggibile => attivazione.segreto
      .replaceAllMapped(RegExp(r'.{4}'), (m) => '${m[0]} ')
      .trim();

  Future<void> _apriApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    var aperta = false;
    try {
      aperta = await launchUrl(
        Uri.parse(attivazione.uri),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      aperta = false;
    }
    if (!aperta) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Nessuna app di autenticazione trovata: inquadra il codice QR o copia la chiave.',
          ),
        ),
      );
    }
  }

  Future<void> _copiaChiave(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: attivazione.segreto));
    messenger.showSnackBar(const SnackBar(content: Text('Chiave copiata')));
  }

  @override
  Widget build(BuildContext context) {
    return JambRiquadro(
      titolo: '2. Collega l\'app',
      children: [
        const Text(
          'Nell\'app aggiungi un account e inquadra questo codice QR.',
          style: _testo,
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SvgPicture.string(
              attivazione.qrSvg,
              width: 200,
              height: 200,
              semanticsLabel: 'Codice QR per l\'app di autenticazione',
            ),
          ),
        ),
        // Sul telefono l'app si apre direttamente: non si può inquadrare
        // lo schermo con cui si sta guardando il codice.
        if (!kIsWeb) ...[
          const SizedBox(height: 12),
          JambPulsanteSecondario(
            icona: Icons.open_in_new_rounded,
            etichetta: 'Apri nell\'app di autenticazione',
            onTap: () => _apriApp(context),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Non riesci a inquadrarlo? Inserisci a mano questa chiave:',
          style: _testo,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                _chiaveLeggibile,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D2660),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Copia la chiave',
              icon: const Icon(Icons.copy_rounded),
              onPressed: () => _copiaChiave(context),
            ),
          ],
        ),
      ],
    );
  }
}
