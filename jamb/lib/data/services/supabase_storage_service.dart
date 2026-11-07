import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamb/core/supabase_client.dart';
import 'package:jamb/data/errori_supabase.dart';
import 'package:jamb/data/services/storage_service.dart';

/// Archivio dei file su Supabase Storage. L'accesso è deciso dalle policy su
/// `storage.objects`, che ricavano gruppo e unità dal percorso.
class SupabaseStorageService implements IStorageService {
  /// Validità degli URL firmati: basta ad aprire il file, non a condividerlo.
  static const int _secondiValiditaUrl = 300;

  @override
  Future<void> carica(String bucket, String percorso, Uint8List byte, String mime) =>
      eseguiSupabase(() async {
        await supabase.storage.from(bucket).uploadBinary(
              percorso,
              byte,
              fileOptions: FileOptions(contentType: mime, upsert: false),
            );
      });

  @override
  Future<String> urlFirmato(String bucket, String percorso) => eseguiSupabase(
        () => supabase.storage.from(bucket).createSignedUrl(percorso, _secondiValiditaUrl),
      );

  @override
  Future<void> elimina(String bucket, List<String> percorsi) => eseguiSupabase(() async {
        if (percorsi.isEmpty) return;
        await supabase.storage.from(bucket).remove(percorsi);
      });
}
