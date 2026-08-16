/// Counts of entity ids that exist on both sides with meaningfully different
/// sync fields (devices / birthdays / tags / places). Logs and tag links are
/// append-only and never counted.
class SyncConflictSummary {
  const SyncConflictSummary({
    this.deviceCount = 0,
    this.birthdayCount = 0,
    this.tagCount = 0,
    this.placeCount = 0,
  });

  final int deviceCount;
  final int birthdayCount;
  final int tagCount;
  final int placeCount;

  int get total => deviceCount + birthdayCount + tagCount + placeCount;

  bool get hasConflicts => total > 0;
}

/// Thrown when [RemoteSyncPort.sync] would override data but
/// [overrideConfirmed] is false.
class SyncOverrideRequiredException implements Exception {
  const SyncOverrideRequiredException(this.summary);

  final SyncConflictSummary summary;

  @override
  String toString() => 'SyncOverrideRequiredException(total: ${summary.total})';
}

/// Port for push+pull remote sync. Implemented in the data layer.
///
/// Conflict policy: **local wins** after explicit confirmation. Additive
/// create/insert and identical rows need no confirmation.
abstract class RemoteSyncPort {
  /// Fetch remote, compare to local, return conflicts. Must not mutate.
  Future<SyncConflictSummary> detectConflicts({required String token});

  /// Push+pull with local-wins. When conflicts exist, [overrideConfirmed]
  /// must be true or this throws [SyncOverrideRequiredException] with no
  /// mutations.
  Future<void> sync({required String token, bool overrideConfirmed = false});
}
