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
import 'package:jamb/ui/core/widgets/jamb_feedback.dart';
import 'package:jamb/domain/repositories/documento_repository.dart';
import 'package:jamb/data/repositories/supabase_documento_repository.dart';

/// Widget radice dell'app: registra la sessione, che vive per tutta la durata
/// dell'app, e sotto di essa l'app legata all'utente corrente.
class JambApp extends StatelessWidget {
  const JambApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Creata subito, non lazy, così si sottoscrive all'auth.
      create: (_) => SessionService(),
      lazy: false,
      child: const _AppPerUtente(),
    );
  }
}

/// Repository, ViewModel e navigazione dell'utente corrente.
///
/// Sono ricreati da zero quando l'utente cambia o esce: nessun dato
/// dell'utente precedente (es. schede sanitarie) resta in memoria, e la
/// navigazione riparte da [AuthGate] anche se la barra in basso ha
/// sostituito la schermata iniziale.
class _AppPerUtente extends StatelessWidget {
  const _AppPerUtente();

  @override
  Widget build(BuildContext context) {
    final userId = context.select<SessionService, String?>((s) => s.userId);

    return MultiProvider(
      key: ValueKey(userId),
      providers: [
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
        return const _AvvisoAccesso(
          'Nessun ruolo assegnato.\nContatta un responsabile del gruppo.',
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
        // Le policy RLS non mostrano dati ai ruoli da ragazzo: invece di
        // schermate vuote, un avviso esplicito.
        if (!session.permessi.puoUsareAreaCapi) {
          return const _AvvisoAccesso(
            "L'area dedicata ai ragazzi non è ancora disponibile.\n"
            "Per ora Jamb è riservata ai capi.",
          );
        }
        return const HomeScreen();
    }
  }
}

/// Messaggio a schermo intero per chi è autenticato ma non può usare l'app,
/// con il pulsante per uscire e accedere con un altro account.
class _AvvisoAccesso extends StatelessWidget {
  final String messaggio;
  const _AvvisoAccesso(this.messaggio);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(messaggio, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => eseguiConFeedback(
                    context, context.read<SessionService>().logout),
                child: const Text('Esci'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}