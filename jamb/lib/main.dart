import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jamb/app.dart';
import 'package:jamb/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Punto di ingresso: inizializza la localizzazione italiana e Supabase,
/// quindi avvia l'app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const JambApp());
}


