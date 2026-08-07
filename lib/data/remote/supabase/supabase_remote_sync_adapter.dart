import 'package:nasyad/domain/sync/remote_sync_port.dart';
import 'package:nasyad/domain/sync/sync_entity_kind.dart';
import 'package:nasyad/domain/sync/sync_mutation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase implementation of [RemoteSyncPort].
/// Remote schema: see `supabase/migrations/`.
class SupabaseRemoteSyncAdapter implements RemoteSyncPort {
  SupabaseRemoteSyncAdapter({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  String get providerName => 'supabase';

  @override
  Future<bool> isConfigured() async => true;

  @override
  Future<bool> isAuthenticated() async => _client.auth.currentUser != null;

  @override
  Future<void> pushMutation(SyncMutation mutation) async {
    final userId = _requireUserId();
    switch (mutation.entityKind) {
      case SyncEntityKind.device:
        await _pushDevice(mutation, userId);
      case SyncEntityKind.deviceLog:
        await _pushDeviceLog(mutation, userId);
      case SyncEntityKind.birthday:
        await _pushBirthday(mutation, userId);
    }
  }

  @override
  Future<List<SyncMutation>> pullChanges({DateTime? updatedSince}) async {
    if (!await isAuthenticated()) return const [];

    final sinceIso =
        (updatedSince ?? DateTime.fromMillisecondsSinceEpoch(0))
            .toUtc()
            .toIso8601String();

    final devices = await _client
        .from('devices')
        .select()
        .gt('updated_at', sinceIso);
    final logs = await _client
        .from('device_logs')
        .select()
        .gt('created_at', sinceIso);
    final birthdays = await _client
        .from('birthdays')
        .select()
        .gt('updated_at', sinceIso);

    return [
      ..._mapDeviceRows(devices as List<dynamic>),
      ..._mapDeviceLogRows(logs as List<dynamic>),
      ..._mapBirthdayRows(birthdays as List<dynamic>),
    ];
  }

  Future<void> _pushDevice(SyncMutation mutation, String userId) async {
    if (mutation.operation == SyncOperation.delete) {
      await _client.from('devices').delete().eq('id', mutation.entityId);
      return;
    }
    await _client.from('devices').upsert({
      ...mutation.payload,
      'user_id': userId,
    });
  }

  Future<void> _pushDeviceLog(SyncMutation mutation, String userId) async {
    if (mutation.operation == SyncOperation.delete) {
      await _client.from('device_logs').delete().eq('id', mutation.entityId);
      return;
    }
    await _client.from('device_logs').upsert({
      ...mutation.payload,
      'user_id': userId,
    });
  }

  Future<void> _pushBirthday(SyncMutation mutation, String userId) async {
    if (mutation.operation == SyncOperation.delete) {
      await _client.from('birthdays').delete().eq('id', mutation.entityId);
      return;
    }
    await _client.from('birthdays').upsert({
      ...mutation.payload,
      'user_id': userId,
    });
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Supabase auth session required for sync');
    }
    return userId;
  }

  List<SyncMutation> _mapDeviceRows(List<dynamic> rows) {
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return SyncMutation(
        id: 'remote:device:${map['id']}',
        entityKind: SyncEntityKind.device,
        operation: SyncOperation.upsert,
        entityId: map['id'] as String,
        payload: map,
        createdAt: DateTime.parse(map['updated_at'] as String),
      );
    }).toList(growable: false);
  }

  List<SyncMutation> _mapDeviceLogRows(List<dynamic> rows) {
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return SyncMutation(
        id: 'remote:device_log:${map['id']}',
        entityKind: SyncEntityKind.deviceLog,
        operation: SyncOperation.upsert,
        entityId: map['id'] as String,
        payload: map,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    }).toList(growable: false);
  }

  List<SyncMutation> _mapBirthdayRows(List<dynamic> rows) {
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return SyncMutation(
        id: 'remote:birthday:${map['id']}',
        entityKind: SyncEntityKind.birthday,
        operation: SyncOperation.upsert,
        entityId: map['id'] as String,
        payload: map,
        createdAt: DateTime.parse(map['updated_at'] as String),
      );
    }).toList(growable: false);
  }
}
