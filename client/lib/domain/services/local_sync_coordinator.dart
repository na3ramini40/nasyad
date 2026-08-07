import 'package:nasyad/core/preferences/sync_preference_store.dart';
import 'package:nasyad/core/sync/network_status_reader.dart';
import 'package:nasyad/domain/services/remote_sync_port.dart';
import 'package:nasyad/domain/services/sync_policy.dart';

/// Outcome of one sync tick. Never throws for gate skips.
enum SyncTickResult {
  /// User turned sync off — no remote side effects.
  skippedDisabled,

  /// Preference on but device offline — no remote side effects.
  skippedOffline,

  /// Preference on and online, but no remote engine / token yet.
  readyButNoRemote,

  /// Push+pull finished without error.
  completed,

  /// Remote attempt ran but failed (partial or total), or conflicts need UI.
  failed,
}

/// Outcome for an explicit sign-in sync attempt.
enum SyncNowOutcome {
  /// Preference off or offline — sync not attempted.
  skipped,

  /// Push+pull succeeded.
  completed,

  /// Attempted and failed; local data remains safe.
  failed,

  /// User cancelled after conflict preview — no override writes.
  cancelled,

  /// Conflicts exist; caller must confirm before [syncNow] with override.
  needsConfirmation,
}

/// Result of [LocalSyncCoordinator.previewSync] — no mutations.
sealed class SyncPreviewResult {
  const SyncPreviewResult();
}

/// Gates skipped or no conflicts — safe to sync without confirm.
final class SyncPreviewReady extends SyncPreviewResult {
  const SyncPreviewReady();
}

/// Conflicts require explicit confirmation before apply.
final class SyncPreviewConflicts extends SyncPreviewResult {
  const SyncPreviewConflicts(this.summary);

  final SyncConflictSummary summary;
}

/// Coordinates when remote sync may run and drives [RemoteSyncPort].
///
/// Local Drift remains the source of truth; sync fills it. Gate failures and
/// missing adapters never throw into UI.
class LocalSyncCoordinator {
  LocalSyncCoordinator({
    required SyncPreferenceStore preferenceStore,
    required NetworkStatusReader networkStatus,
    RemoteSyncPort? remoteEngine,
  }) : _preferenceStore = preferenceStore,
       _networkStatus = networkStatus,
       _remoteEngine = remoteEngine;

  final SyncPreferenceStore _preferenceStore;
  final NetworkStatusReader _networkStatus;
  final RemoteSyncPort? _remoteEngine;

  Future<SyncTickResult> tick({
    String? token,
    bool overrideConfirmed = false,
  }) async {
    final preferenceEnabled = await _preferenceStore.read();
    if (!preferenceEnabled) {
      return SyncTickResult.skippedDisabled;
    }

    final isOnline = await _networkStatus.isOnline;
    if (!SyncPolicy.shouldAttemptRemoteSync(
      preferenceEnabled: preferenceEnabled,
      isOnline: isOnline,
    )) {
      return SyncTickResult.skippedOffline;
    }

    final engine = _remoteEngine;
    if (engine == null || token == null || token.isEmpty) {
      return SyncTickResult.readyButNoRemote;
    }

    try {
      await engine.sync(token: token, overrideConfirmed: overrideConfirmed);
      return SyncTickResult.completed;
    } on SyncOverrideRequiredException {
      // Background tick must not silently override — treat as soft failure.
      return SyncTickResult.failed;
    } catch (_) {
      return SyncTickResult.failed;
    }
  }

  /// Compare local vs remote without writing. Used before sign-in apply.
  Future<SyncPreviewResult> previewSync({required String token}) async {
    final preferenceEnabled = await _preferenceStore.read();
    if (!preferenceEnabled) {
      return const SyncPreviewReady();
    }

    final isOnline = await _networkStatus.isOnline;
    if (!SyncPolicy.shouldAttemptRemoteSync(
      preferenceEnabled: preferenceEnabled,
      isOnline: isOnline,
    )) {
      return const SyncPreviewReady();
    }

    final engine = _remoteEngine;
    if (engine == null || token.isEmpty) {
      return const SyncPreviewReady();
    }

    try {
      final summary = await engine.detectConflicts(token: token);
      if (summary.hasConflicts) {
        return SyncPreviewConflicts(summary);
      }
      return const SyncPreviewReady();
    } catch (_) {
      // Preview failure → caller may still attempt sync and surface soft fail.
      return const SyncPreviewReady();
    }
  }

  /// Sign-in path: attempt push+pull when gated on; never throws.
  ///
  /// When conflicts exist and [overrideConfirmed] is false, returns
  /// [SyncNowOutcome.needsConfirmation] without mutating.
  Future<SyncNowOutcome> syncNow({
    required String token,
    bool overrideConfirmed = false,
  }) async {
    final preferenceEnabled = await _preferenceStore.read();
    if (!preferenceEnabled) {
      return SyncNowOutcome.skipped;
    }

    final isOnline = await _networkStatus.isOnline;
    if (!SyncPolicy.shouldAttemptRemoteSync(
      preferenceEnabled: preferenceEnabled,
      isOnline: isOnline,
    )) {
      return SyncNowOutcome.skipped;
    }

    final engine = _remoteEngine;
    if (engine == null || token.isEmpty) {
      return SyncNowOutcome.skipped;
    }

    try {
      if (!overrideConfirmed) {
        final summary = await engine.detectConflicts(token: token);
        if (summary.hasConflicts) {
          return SyncNowOutcome.needsConfirmation;
        }
      }
      await engine.sync(token: token, overrideConfirmed: overrideConfirmed);
      return SyncNowOutcome.completed;
    } on SyncOverrideRequiredException {
      return SyncNowOutcome.needsConfirmation;
    } catch (_) {
      return SyncNowOutcome.failed;
    }
  }
}
