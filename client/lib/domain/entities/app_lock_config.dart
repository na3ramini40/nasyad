import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/lock_idle_timeout.dart';
import 'package:nasyad/domain/entities/lock_method.dart';

/// Persisted app-lock preferences (method + timeout). Secrets live elsewhere.
final class AppLockConfig extends Equatable {
  const AppLockConfig({
    this.method,
    this.timeout = LockIdleTimeout.defaultValue,
  });

  /// `null` means lock is unset (off).
  final LockMethod? method;
  final LockIdleTimeout timeout;

  bool get isEnabled => method != null;

  static const unset = AppLockConfig();

  AppLockConfig copyWith({
    LockMethod? method,
    LockIdleTimeout? timeout,
    bool clearMethod = false,
  }) {
    return AppLockConfig(
      method: clearMethod ? null : (method ?? this.method),
      timeout: timeout ?? this.timeout,
    );
  }

  @override
  List<Object?> get props => [method, timeout];
}
