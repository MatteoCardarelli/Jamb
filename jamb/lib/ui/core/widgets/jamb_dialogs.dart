import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';

/// Classe di utilità per la visualizzazione di dialoghi modali standardizzati:
/// richiesta di un nome (cartelle, rinomina) e conferme.
class JambDialogs {
  /// Chiede un nome (es. di una nuova cartella, o il nuovo nome di un file);
  /// restituisce il nome ripulito, o `null` se l'utente annulla. [valida]
  /// restituisce il motivo per cui un nome non va bene, mostrato sotto il campo.
  static Future<String?> chiediNome(
    BuildContext context, {
    required String titolo,
    required IconData icona,
    required String conferma,
    String iniziale = '',
    String? Function(String nome)? valida,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => _DialogoNome(
        titolo: titolo,
        icona: icona,
        conferma: conferma,
        iniziale: iniziale,
        valida: valida,
      ),
    );
  }

  /// Chiede di scegliere tra [opzioni] (etichetta e valore, una per riga);
  /// restituisce il valore scelto, o `null` se l'utente annulla. Con
  /// [pericolosa] le opzioni sono rosse (es. scegliere cosa eliminare).
  static Future<T?> scegli<T>(
    BuildContext context, {
    required String titolo,
    required String messaggio,
    required List<(String, T)> opzioni,
    bool pericolosa = false,
  }) {
    final colore = pericolosa ? const Color(0xFFB91C1C) : const Color(0xFF1D2660);
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          titolo,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D2660),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              messaggio,
              style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            for (final (etichetta, valore) in opzioni)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(valore),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colore,
                    side: BorderSide(color: colore.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    etichetta,
                    style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              "ANNULLA",
              style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Chiede conferma prima di un'eliminazione; restituisce `true` solo se
  /// l'utente sceglie «Elimina».
  static Future<bool> confermaEliminazione(
    BuildContext context, {
    required String titolo,
    required String messaggio,
  }) =>
      conferma(context, titolo: titolo, messaggio: messaggio, etichetta: "ELIMINA");

  /// Chiede conferma prima di un'azione che fa perdere dati (eliminare,
  /// uscire senza salvare); restituisce `true` solo se l'utente sceglie
  /// [etichetta], mostrata sul pulsante rosso.
  static Future<bool> conferma(
    BuildContext context, {
    required String titolo,
    required String messaggio,
    required String etichetta,
  }) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          titolo,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D2660),
          ),
        ),
        content: Text(
          messaggio,
          style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              "ANNULLA",
              style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              etichetta,
              style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return conferma ?? false;
  }
}

// --- DIALOGHI SPECIFICI ---

/// Dialogo con un campo per il nome; «conferma» è attivo solo se il nome
/// supera la validazione.
class _DialogoNome extends StatefulWidget {
  final String titolo;
  final IconData icona;
  final String conferma;
  final String iniziale;
  final String? Function(String nome)? valida;

  const _DialogoNome({
    required this.titolo,
    required this.icona,
    required this.conferma,
    required this.iniziale,
    this.valida,
  });

  @override
  State<_DialogoNome> createState() => _DialogoNomeState();
}

class _DialogoNomeState extends State<_DialogoNome> {
  late final TextEditingController _nome = TextEditingController(text: widget.iniziale);

  /// Il messaggio d'errore compare solo dopo che l'utente ha scritto.
  bool _modificato = false;

  String? get _errore => widget.valida?.call(_nome.text);

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errore = _errore;
    return _BaseDialog(
      titolo: widget.titolo,
      icona: widget.icona,
      confirmLabel: widget.conferma,
      onConfirm: errore == null ? () => Navigator.pop(context, _nome.text.trim()) : null,
      child: Column(
        children: [
          const Align(alignment: Alignment.centerLeft, child: JambEtichettaCampo('Nome')),
          TextField(
            controller: _nome,
            autofocus: true,
            onChanged: (_) => setState(() => _modificato = true),
            decoration: jambDecorazioneCampo('Es. Verbali 2026')
                .copyWith(errorText: _modificato ? errore : null),
          ),
        ],
      ),
    );
  }
}

/// Struttura di base per i dialoghi modali, garantisce coerenza tra titolo, icone e bottoni.
class _BaseDialog extends StatelessWidget {
  final String titolo;
  final IconData icona;
  final Widget child;
  final VoidCallback? onConfirm;
  final String confirmLabel;

  const _BaseDialog({
    required this.titolo,
    required this.icona,
    required this.child,
    required this.onConfirm,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // INTESTAZIONE
            Row(
              children: [
                Icon(icona, color: const Color(0xFF1D2660), size: 24),
                const SizedBox(width: 12),
                Text(
                  titolo,
                  style: const TextStyle(
                    color: Color(0xFF1D2660),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // CORPO DEL DIALOGO
            child,
            
            const SizedBox(height: 32),
            
            // TASTI DI AZIONE
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "ANNULLA",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D2660),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
