import 'package:nasyad/data/remote/supabase/supabase_config.dart';
import 'package:nasyad/data/remote/supabase/supabase_remote_sync_adapter.dart';
import 'package:nasyad/data/sync/no_op_remote_sync_port.dart';
import 'package:nasyad/domain/sync/remote_sync_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSyncBootstrap {
  const SupabaseSyncBootstrap._();

  static Future<RemoteSyncPort> createRemoteSyncPort({
    SupabaseConfig config = SupabaseConfig.fromEnvironment,
  }) async {
    if (!config.isConfigured) {
      return const NoOpRemoteSyncPort();
    }

    if (!Supabase.instance.isInitialized) {
      await Supabase.initialize(
        url: config.url,
        anonKey: config.anonKey,
      );
    }

    return SupabaseRemoteSyncAdapter(client: Supabase.instance.client);
  }
}
