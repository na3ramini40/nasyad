import 'package:nasyad/domain/entities/app_config_snapshot.dart';

/// Local-first remote feature flags. Never blocks launch on network.
abstract class AppConfigRepository {
  /// In-memory snapshot (cache or defaults). Sync read path.
  AppConfigSnapshot get current;

  /// Unknown / missing keys → `false`.
  bool isEnabled(String key);

  /// Yields [current] then subsequent updates after hydrate / successful refresh.
  Stream<AppConfigSnapshot> watch();

  /// Load last-known cache into memory (no network).
  Future<void> hydrate();

  /// Best-effort fetch. On success writes cache and notifies; on failure keeps
  /// last-known (or defaults). Does not throw.
  Future<void> refresh({String? token});
}
