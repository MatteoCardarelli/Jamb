import 'package:flutter/material.dart';
import 'package:jamb/ui/home/widgets/home_screen.dart';
import 'package:jamb/ui/home/view_model/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:jamb/ui/amministrazione/view_model/amministrazione_view_model.dart';
import 'package:jamb/ui/contabilita/view_model/contabilita_view_model.dart';
import 'package:jamb/ui/ragazzi/view_model/ragazzi_view_model.dart';
import 'package:jamb/ui/documenti/view_model/documenti_view_model.dart';
import 'package:jamb/domain/repositories/scout_repository.dart';
import 'package:jamb/domain/repositories/obiettivo_repository.dart';
import 'package:jamb/domain/repositories/transazione_repository.dart';
import 'package:jamb/data/repositories/json_scout_repository.dart';
import 'package:jamb/data/repositories/json_obiettivo_repository.dart';
import 'package:jamb/data/repositories/json_transazione_repository.dart';

void main() {
  runApp(const JambApp());
}

class JambApp extends StatelessWidget {
  const JambApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        ChangeNotifierProvider<IScoutRepository>(create: (_) => JsonScoutRepository()),
        Provider<IObiettivoRepository>(create: (_) => JsonObiettivoRepository()),
        ChangeNotifierProvider<ITransazioneRepository>(create: (_) => JsonTransazioneRepository()),

        // ViewModels
        ChangeNotifierProvider(
          create: (context) => AmministrazioneViewModel(context.read<IScoutRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ContabilitaViewModel(context.read<ITransazioneRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(
            context.read<IScoutRepository>(),
            context.read<IObiettivoRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RagazziViewModel(context.read<IScoutRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => DocumentiViewModel()),
      ],
      child: MaterialApp(
        title: 'Jamb MVP',
        debugShowCheckedModeBanner: true,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF003366),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
