import 'package:flutter/material.dart';
import 'package:jamb/domain/entities/sottogruppi.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';

/// Dialogo per scegliere più persone tra i [candidati]; restituisce gli id
/// scelti, o `null` se si annulla. Usato per sottogruppi e pattuglie.
Future<Set<String>?> scegliPersone(
  BuildContext context, {
  required String titolo,
  required List<MembroUnita> candidati,
  required Set<String> iniziali,
  required String testoVuoto,
}) {
  return showDialog<Set<String>>(
    context: context,
    builder: (_) => _DialogoPersone(
      titolo: titolo,
      candidati: candidati,
      iniziali: iniziali,
      testoVuoto: testoVuoto,
    ),
  );
}

class _DialogoPersone extends StatefulWidget {
  final String titolo;
  final List<MembroUnita> candidati;
  final Set<String> iniziali;
  final String testoVuoto;

  const _DialogoPersone({
    required this.titolo,
    required this.candidati,
    required this.iniziali,
    required this.testoVuoto,
  });

  @override
  State<_DialogoPersone> createState() => _DialogoPersoneState();
}

class _DialogoPersoneState extends State<_DialogoPersone> {
  late final Set<String> _scelti = {...widget.iniziali};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.titolo,
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w900,
          color: Color(0xFF1D2660),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.candidati.isEmpty
            ? JambTestoVuoto(widget.testoVuoto)
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final m in widget.candidati)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _scelti.contains(m.id),
                      title: Text(
                        m.nome,
                        style: const TextStyle(fontFamily: 'Lexend'),
                      ),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _scelti.add(m.id);
                        } else {
                          _scelti.remove(m.id);
                        }
                      }),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ANNULLA'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_scelti),
          child: const Text('SALVA'),
        ),
      ],
    );
  }
}
