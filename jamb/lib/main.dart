import 'package:flutter/material.dart';
// Importiamo il widget che abbiamo creato nel path specifico
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';

void main() {
  runApp(const JambApp());
}

class JambApp extends StatelessWidget {
  const JambApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jamb MVP',
      debugShowCheckedModeBanner: true, // Utile in fase di debug
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF003366), // Blu scout AGESCI come base
      ),
      // Impostiamo la tua schermata come home
      home: const EmptyBackgroundScreen(),
    );
  }
}
