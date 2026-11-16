import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamb/ui/core/widgets/jamb_campo.dart';

/// Campo per il codice di 6 cifre dell'app di autenticazione (accesso e
/// attivazione della verifica in due passaggi).
class CampoCodice extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  const CampoCodice({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 8,
      ),
      decoration: jambDecorazioneCampo('000000', icona: Icons.pin_outlined),
      onSubmitted: onSubmitted,
    );
  }
}
