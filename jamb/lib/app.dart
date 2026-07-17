import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'package:jamb/data/repositories/supabase_scout_repository.dart';
import 'package:jamb/data/repositories/supabase_obiettivo_repository.dart';
import 'package:jamb/data/repositories/supabase_transazione_repository.dart';
import 'package:jamb/domain/repositories/evento_repository.dart';
import 'package:jamb/data/repositories/supabase_evento_repository.dart';
import 'package:jamb/ui/calendario/view_model/calendario_view_model.dart';
import 'package:jamb/ui/auth/widgets/login_screen.dart';
import 'package:jamb/core/session_service.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/data/repositories/supabase_documento_repository.dart';

/// Widget radice dell'app: registra sessione, repository e ViewModel (Provider)
/// e configura [MaterialApp] con localizzazione italiana e tema.
class JambApp extends StatelessWidget {
  const JambApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Sessione (creata subito, non lazy, così si sottoscrive all'auth)
        ChangeNotifierProvider(create: (_) => SessionService(), lazy: false),

        // Repositories
        ChangeNotifierProvider<IScoutRepository>(create: (ctx) => SupabaseScoutRepository(ctx.read<SessionService>())),
        Provider<IObiettivoRepository>(create: (ctx) => SupabaseObiettivoRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<ITransazioneRepository>(create: (ctx) => SupabaseTransazioneRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<IEventoRepository>(create: (ctx) => SupabaseEventoRepository(ctx.read<SessionService>())),
        Provider<IDocumentoRepository>(create: (ctx) => SupabaseDocumentoRepository(ctx.read<SessionService>())),

        // ViewModels
        ChangeNotifierProvider(create: (context) => AmministrazioneViewModel(context.read<IScoutRepository>())),
        ChangeNotifierProvider(create: (context) => ContabilitaViewModel(context.read<ITransazioneRepository>())),
        ChangeNotifierProvider(create: (context) => HomeViewModel(context.read<IScoutRepository>(), context.read<IObiettivoRepository>())),
        ChangeNotifierProvider(create: (context) => RagazziViewModel(context.read<IScoutRepository>())),
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
        home: const AuthGate(),
      ),
    );
  }
}

/// Sceglie la schermata iniziale in base allo stato della sessione:
/// login, caricamento, "nessun ruolo", errore oppure Home.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionService>();

    switch (session.status) {
      case SessionStatus.unauthenticated:
        return LoginScreen();

      case SessionStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case SessionStatus.noMembership:
        return const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Nessun ruolo assegnato.\nContatta un responsabile del gruppo.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );

      case SessionStatus.error:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Errore nel caricamento della sessione.'),
                TextButton(
                  onPressed: () => context.read<SessionService>().load(),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          ),
        );

      case SessionStatus.ready:
        return const HomeScreen();
    }
  }
}