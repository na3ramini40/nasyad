import 'package:nasyad/domain/sync/sync_mutation.dart';

/// Provider-agnostic remote backend (Supabase today; swappable later).
abstract class RemoteSyncPort {
  String get providerName;

  Future<bool> isConfigured();

  Future<bool> isAuthenticated();

  Future<void> pushMutation(SyncMutation mutation);

  Future<List<SyncMutation>> pullChanges({DateTime? updatedSince});
}
