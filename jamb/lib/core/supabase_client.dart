import 'package:supabase_flutter/supabase_flutter.dart';

/// Istanza condivisa del client Supabase, usata da tutti i repository.
final supabase = Supabase.instance.client;
