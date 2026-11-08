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
import 'package:jamb/domain/repositories/avviso_repository.dart';
import 'package:jamb/data/repositories/supabase_avviso_repository.dart';
import 'package:jamb/ui/bacheca/view_model/bacheca_view_model.dart';
import 'package:jamb/domain/repositories/presenza_repository.dart';
import 'package:jamb/data/repositories/supabase_presenza_repository.dart';
import 'package:jamb/domain/repositories/sottogruppo_repository.dart';
import 'package:jamb/data/repositories/supabase_sottogruppo_repository.dart';
import 'package:jamb/domain/repositories/pillola_repository.dart';
import 'package:jamb/data/repositories/supabase_pillola_repository.dart';
import 'package:jamb/ui/pillole/view_model/pillole_view_model.dart';
import 'package:jamb/domain/repositories/incarichi_repository.dart';
import 'package:jamb/data/repositories/supabase_incarichi_repository.dart';
import 'package:jamb/ui/assistente/widgets/area_assistente_screen.dart';
import 'package:jamb/domain/repositories/formazione_repository.dart';
import 'package:jamb/data/repositories/supabase_formazione_repository.dart';
import 'package:jamb/domain/repositories/peg_repository.dart';
import 'package:jamb/data/repositories/supabase_peg_repository.dart';
import 'package:jamb/domain/repositories/veglia_repository.dart';
import 'package:jamb/data/repositories/supabase_veglia_repository.dart';
import 'package:jamb/data/services/storage_service.dart';
import 'package:jamb/data/services/supabase_storage_service.dart';

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

/// Repository, ViewModel e navigazione dell'utente corrente nell'unità attiva.
///
/// Sono ricreati da zero quando l'utente cambia, esce o cambia unità: nessun
/// dato dell'utente o dell'unità precedente (es. schede sanitarie) resta in
/// memoria, e la navigazione riparte da [AuthGate] anche se la barra in basso
/// ha sostituito la schermata iniziale.
class _AppPerUtente extends StatelessWidget {
  const _AppPerUtente();

  @override
  Widget build(BuildContext context) {
    final userId = context.select<SessionService, String?>((s) => s.userId);
    final unitId = context.select<SessionService, String?>((s) => s.activeUnitId);

    return MultiProvider(
      key: ValueKey('$userId/$unitId'),
      providers: [
        // Archivio dei file, usato dai repository di documenti e transazioni
        Provider<IStorageService>(create: (_) => SupabaseStorageService()),

        // Repositories
        ChangeNotifierProvider<IScoutRepository>(create: (ctx) => SupabaseScoutRepository(ctx.read<SessionService>())),
        Provider<IObiettivoRepository>(create: (ctx) => SupabaseObiettivoRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<ITransazioneRepository>(create: (ctx) => SupabaseTransazioneRepository(ctx.read<SessionService>(), ctx.read<IStorageService>())),
        ChangeNotifierProvider<IEventoRepository>(create: (ctx) => SupabaseEventoRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<IDocumentoRepository>(create: (ctx) => SupabaseDocumentoRepository(ctx.read<SessionService>(), ctx.read<IStorageService>())),
        ChangeNotifierProvider<IAvvisoRepository>(create: (ctx) => SupabaseAvvisoRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<IPresenzaRepository>(create: (_) => SupabasePresenzaRepository()),
        ChangeNotifierProvider<ISottogruppoRepository>(create: (ctx) => SupabaseSottogruppoRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<IPillolaRepository>(create: (ctx) => SupabasePillolaRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<IIncarichiRepository>(create: (ctx) => SupabaseIncarichiRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<IFormazioneRepository>(create: (ctx) => SupabaseFormazioneRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<IPegRepository>(create: (ctx) => SupabasePegRepository(ctx.read<SessionService>())),
        ChangeNotifierProvider<IVegliaRepository>(create: (ctx) => SupabaseVegliaRepository(ctx.read<SessionService>())),

        // ViewModels
        ChangeNotifierProvider(create: (context) => AmministrazioneViewModel(context.read<IScoutRepository>())),
        ChangeNotifierProvider(create: (context) => ContabilitaViewModel(context.read<ITransazioneRepository>())),
        ChangeNotifierProvider(create: (context) => HomeViewModel(context.read<IScoutRepository>(), context.read<IObiettivoRepository>())),
        ChangeNotifierProvider(create: (context) => RagazziViewModel(context.read<IScoutRepository>())),
        ChangeNotifierProvider(create: (context) => DocumentiViewModel(context.read<IDocumentoRepository>())),
        ChangeNotifierProvider(create: (context) => CalendarioViewModel(context.read<IEventoRepository>())),
        // Unico per l'app: la campanella della TopBar ne legge i non letti.
        ChangeNotifierProvider(create: (context) => BachecaViewModel(context.read<IAvvisoRepository>())),
        ChangeNotifierProvider(create: (context) => PilloleViewModel(context.read<IPillolaRepository>())),
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
          if (session.permessi.assistenteEcclesiastico) return const AreaAssistenteScreen();
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