/// Local-first sync gate.
///
/// **Contract**
/// - Drift / local repositories are always the UI source of truth.
/// - The UI never awaits remote work; screens read local data only.
/// - Remote sync may be attempted only when the user preference is enabled
///   **and** the device appears online. Otherwise the app stays local-only.
class SyncPolicy {
  const SyncPolicy._();

  /// Returns true only when both preference and connectivity allow a remote
  /// attempt. Callers still must not block UI on remote results.
  static bool shouldAttemptRemoteSync({
    required bool preferenceEnabled,
    required bool isOnline,
  }) {
    return preferenceEnabled && isOnline;
  }
}
