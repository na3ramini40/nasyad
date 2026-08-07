import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/sync/sync_entity_kind.dart';

/// One local or remote change tracked by the sync outbox.
class SyncMutation extends Equatable {
  const SyncMutation({
    required this.id,
    required this.entityKind,
    required this.operation,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final SyncEntityKind entityKind;
  final SyncOperation operation;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    entityKind,
    operation,
    entityId,
    payload,
    createdAt,
  ];
}

class SyncResult extends Equatable {
  const SyncResult({
    required this.pushedCount,
    required this.pulledCount,
    required this.failedCount,
    this.errors = const [],
  });

  const SyncResult.idle()
    : pushedCount = 0,
      pulledCount = 0,
      failedCount = 0,
      errors = const [];

  final int pushedCount;
  final int pulledCount;
  final int failedCount;
  final List<String> errors;

  bool get hasErrors => failedCount > 0 || errors.isNotEmpty;

  @override
  List<Object?> get props => [pushedCount, pulledCount, failedCount, errors];
}

class SyncStatus extends Equatable {
  const SyncStatus({
    required this.pendingCount,
    required this.lastSyncedAt,
    required this.remoteConfigured,
    required this.remoteAuthenticated,
  });

  const SyncStatus.initial()
    : pendingCount = 0,
      lastSyncedAt = null,
      remoteConfigured = false,
      remoteAuthenticated = false;

  final int pendingCount;
  final DateTime? lastSyncedAt;
  final bool remoteConfigured;
  final bool remoteAuthenticated;

  @override
  List<Object?> get props => [
    pendingCount,
    lastSyncedAt,
    remoteConfigured,
    remoteAuthenticated,
  ];
}
