import 'package:flutter/material.dart';
import 'package:jamb/ui/views/home/home_view.dart';
import 'package:provider/provider.dart';
import 'package:jamb/core/providers/amministrazione_provider.dart';
import 'package:jamb/core/providers/contabilita_provider.dart';

void main() {
  runApp(const JambApp());
}

class JambApp extends StatelessWidget {
  const JambApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AmministrazioneProvider()),
        ChangeNotifierProvider(create: (_) => ContabilitaProvider()),
      ],
      child: MaterialApp(
        title: 'Jamb MVP',
        debugShowCheckedModeBanner: true,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF003366),
        ),
        home: const HomeView(),
      ),
    );
  }
}
