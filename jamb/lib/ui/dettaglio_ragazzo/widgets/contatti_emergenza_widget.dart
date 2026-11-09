import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/jamb_stati.dart';
import 'package:jamb/domain/entities/scout.dart'; // Importa entità di dominio
import 'package:jamb/ui/core/widgets/jamb_riga_contatto.dart';
import 'package:jamb/ui/core/widgets/jamb_riquadro.dart';

/// Widget che visualizza la lista dei contatti di emergenza dello scout.
/// Utilizza l'entità di dominio [ContattoEmergenza] (Shared Model).
class ContattiEmergenzaWidget extends StatelessWidget {
  /// Lista dei contatti da visualizzare
  final List<ContattoEmergenza> contatti;

  const ContattiEmergenzaWidget({super.key, required this.contatti});

  @override
  Widget build(BuildContext context) {
    return JambRiquadro(
      titolo: "Contatti di emergenza",
      children: [
        if (contatti.isEmpty)
          const JambTestoVuoto("Nessun contatto registrato.")
        else
          ...List.generate(contatti.length, (index) {
            return Column(
              children: [
                if (index > 0)
                  const Divider(color: Color(0xFFF1F5F9), height: 32, thickness: 1.5),
                if (index == 0) const SizedBox(height: 8),
                JambRigaContatto(
                  etichetta: contatti[index].nome,
                  telefono: contatti[index].telefono,
                ),
              ],
            );
          }),
      ],
    );
  }
}
