import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
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
import 'package:jamb/domain/repositories/evento_repository.dart';
import 'package:jamb/data/repositories/json_evento_repository.dart';
import 'package:jamb/ui/calendario/view_model/calendario_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
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
        ChangeNotifierProvider<IEventoRepository>(create: (_) => JsonEventoRepository()),

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
        ChangeNotifierProvider(create: (context) => CalendarioViewModel(context.read<IEventoRepository>())),
      ],
      child: MaterialApp(
        title: 'Jamb MVP',
        debugShowCheckedModeBanner: true,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it', 'IT'),
        ],
        locale: const Locale('it', 'IT'),
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF003366),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
