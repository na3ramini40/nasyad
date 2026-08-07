import 'package:nasyad/domain/sync/remote_sync_port.dart';
import 'package:nasyad/domain/sync/sync_mutation.dart';

/// Default remote backend when sync is disabled or not configured.
class NoOpRemoteSyncPort implements RemoteSyncPort {
  const NoOpRemoteSyncPort();

  @override
  String get providerName => 'none';

  @override
  Future<bool> isConfigured() async => false;

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<void> pushMutation(SyncMutation mutation) async {}

  @override
  Future<List<SyncMutation>> pullChanges({DateTime? updatedSince}) async {
    return const [];
  }
}
