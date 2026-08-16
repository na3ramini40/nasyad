import 'dart:convert';

import 'package:nasyad/core/sync/sync_state_store.dart';
import 'package:nasyad/data/datasources/birthday_local_datasource.dart';
import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/datasources/sync_remote_datasource.dart';
import 'package:nasyad/data/datasources/tag_local_datasource.dart';
import 'package:nasyad/data/models/birthday_model.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/models/device_tag_link_model.dart';
import 'package:nasyad/data/models/tag_model.dart';
import 'package:nasyad/domain/services/remote_sync_port.dart';

/// Push-then-pull sync engine. Drift stays the UI source of truth.
///
/// Conflict policy: **local wins** for devices/birthdays/tags after confirm;
/// logs and device–tag links are append-only (insert if missing id / pair).
///
/// Tags and links: this install’s local catalog is authoritative on push —
/// upsert all local rows, then DELETE remote tags/links absent locally
/// (same class of limitation as birthday delete; no tombstones).
///
/// Device log pull does **not** re-apply usage/maintenance side effects:
/// server applies them on create and bumps device `updated_at`; device rows
/// remain the field source of truth after push order devices → logs.
class RemoteSyncEngine implements RemoteSyncPort {
  RemoteSyncEngine({
    required SyncRemoteDataSource remote,
    required DeviceLocalDataSource devices,
    required DeviceLogLocalDataSource logs,
    required BirthdayLocalDataSource birthdays,
    required TagLocalDataSource tags,
    required SyncStateStore syncState,
  }) : _remote = remote,
       _devices = devices,
       _logs = logs,
       _birthdays = birthdays,
       _tags = tags,
       _syncState = syncState;

  final SyncRemoteDataSource _remote;
  final DeviceLocalDataSource _devices;
  final DeviceLogLocalDataSource _logs;
  final BirthdayLocalDataSource _birthdays;
  final TagLocalDataSource _tags;
  final SyncStateStore _syncState;

  @override
  Future<SyncConflictSummary> detectConflicts({required String token}) async {
    final remoteDevices = await _remote.listDevices(token: token);
    final localDevices = await _devices.getAllDevices();
    final localDeviceById = {for (final d in localDevices) d.id: d};

    var deviceCount = 0;
    for (final remote in remoteDevices) {
      final local = localDeviceById[remote.id];
      if (local != null && !devicesMeaningfullyEqual(local, remote)) {
        deviceCount++;
      }
    }

    final remoteBirthdays = await _remote.listBirthdays(token: token);
    final localBirthdays = await _birthdays.getAllBirthdays();
    final localBirthdayById = {for (final b in localBirthdays) b.id: b};

    var birthdayCount = 0;
    for (final remote in remoteBirthdays) {
      final local = localBirthdayById[remote.id];
      if (local != null && !birthdaysMeaningfullyEqual(local, remote)) {
        birthdayCount++;
      }
    }

    final remoteTags = await _remote.listTags(token: token);
    final localTags = await _tags.getAllTags();
    final localTagById = {for (final t in localTags) t.id: t};

    var tagCount = 0;
    for (final remote in remoteTags) {
      final local = localTagById[remote.id];
      if (local != null && !tagsMeaningfullyEqual(local, remote)) {
        tagCount++;
      }
    }

    return SyncConflictSummary(
      deviceCount: deviceCount,
      birthdayCount: birthdayCount,
      tagCount: tagCount,
    );
  }

  /// Runs full sync. Continues after per-resource errors; rethrows the first
  /// error at the end so callers can surface a soft failure.
  ///
  /// When conflicts exist and [overrideConfirmed] is false, throws
  /// [SyncOverrideRequiredException] before any write.
  @override
  Future<void> sync({
    required String token,
    bool overrideConfirmed = false,
  }) async {
    final summary = await detectConflicts(token: token);
    if (summary.hasConflicts && !overrideConfirmed) {
      throw SyncOverrideRequiredException(summary);
    }

    Object? firstError;

    Future<void> step(Future<void> Function() run) async {
      try {
        await run();
      } catch (error) {
        firstError ??= error;
      }
    }

    await step(() => _pushDevices(token));
    await step(() => _pushLogs(token));
    await step(() => _pushBirthdays(token));
    await step(() => _pushTags(token));
    await step(() => _pushDeviceTagLinks(token));
    await step(() => _pullDevices(token));
    await step(() => _pullLogs(token));
    await step(() => _pullBirthdays(token));
    await step(() => _pullTags(token));
    await step(() => _pullDeviceTagLinks(token));

    if (firstError != null) {
      throw firstError!;
    }
  }

  Future<void> _pushDevices(String token) async {
    final remoteRows = await _remote.listDevices(token: token);
    final remoteById = {for (final d in remoteRows) d.id: d};
    final local = await _devices.getAllDevices();

    for (final device in local) {
      var toPush = device;
      final remote = remoteById[device.id];
      if (remote != null &&
          !devicesMeaningfullyEqual(device, remote) &&
          !device.updatedAt.toUtc().isAfter(remote.updatedAt.toUtc())) {
        toPush = deviceWithUpdatedAt(
          device,
          syncBumpUpdatedAt(device.updatedAt, remote.updatedAt),
        );
        await _devices.upsertDevice(toPush);
      }
      await _remote.upsertDevice(token: token, device: toPush);
    }
  }

  Future<void> _pushLogs(String token) async {
    final local = await _logs.getAllLogs();
    for (final log in local) {
      await _remote.upsertDeviceLog(token: token, log: log);
    }
  }

  Future<void> _pushBirthdays(String token) async {
    final remoteRows = await _remote.listBirthdays(token: token);
    final remoteById = {for (final b in remoteRows) b.id: b};
    final local = await _birthdays.getAllBirthdays();

    for (final birthday in local) {
      var toPush = birthday;
      final remote = remoteById[birthday.id];
      if (remote != null &&
          !birthdaysMeaningfullyEqual(birthday, remote) &&
          !birthday.updatedAt.toUtc().isAfter(remote.updatedAt.toUtc())) {
        toPush = birthdayWithUpdatedAt(
          birthday,
          syncBumpUpdatedAt(birthday.updatedAt, remote.updatedAt),
        );
        await _birthdays.upsertBirthday(toPush);
      }
      await _remote.upsertBirthday(token: token, birthday: toPush);
    }
  }

  /// Local tag catalog wins: upsert all local, then DELETE remote-only ids.
  Future<void> _pushTags(String token) async {
    final remoteRows = await _remote.listTags(token: token);
    final remoteById = {for (final t in remoteRows) t.id: t};
    final local = await _tags.getAllTags();
    final localIds = {for (final t in local) t.id};

    for (final tag in local) {
      var toPush = tag;
      final remote = remoteById[tag.id];
      if (remote != null &&
          !tagsMeaningfullyEqual(tag, remote) &&
          !tag.updatedAt.toUtc().isAfter(remote.updatedAt.toUtc())) {
        toPush = tagWithUpdatedAt(
          tag,
          syncBumpUpdatedAt(tag.updatedAt, remote.updatedAt),
        );
        await _tags.upsertTag(toPush);
      }
      await _remote.upsertTag(token: token, tag: toPush);
    }

    for (final remote in remoteRows) {
      if (!localIds.contains(remote.id)) {
        await _remote.deleteTag(token: token, id: remote.id);
      }
    }
  }

  /// Local link set wins: upsert all local, then DELETE remote-only pairs.
  Future<void> _pushDeviceTagLinks(String token) async {
    final local = await _tags.getDeviceTagLinks();
    final localKeys = {
      for (final link in local) _linkKey(link.deviceId, link.tagId),
    };

    for (final link in local) {
      await _remote.upsertDeviceTagLink(token: token, link: link);
    }

    final remoteRows = await _remote.listDeviceTagLinks(token: token);
    for (final remote in remoteRows) {
      if (!localKeys.contains(_linkKey(remote.deviceId, remote.tagId))) {
        await _remote.deleteDeviceTagLink(
          token: token,
          deviceId: remote.deviceId,
          tagId: remote.tagId,
        );
      }
    }
  }

  Future<void> _pullDevices(String token) async {
    final cursor = await _syncState.readDevicesUpdatedSince();
    final remote = await _remote.listDevices(
      token: token,
      updatedSince: cursor,
    );
    DateTime? maxUpdated = cursor;
    for (final row in remote) {
      await mergeDeviceLocalWins(localStore: _devices, remote: row);
      final updated = row.updatedAt.toUtc();
      if (maxUpdated == null || updated.isAfter(maxUpdated)) {
        maxUpdated = updated;
      }
    }
    if (maxUpdated != null &&
        (cursor == null || maxUpdated.isAfter(cursor.toUtc()))) {
      await _syncState.writeDevicesUpdatedSince(maxUpdated);
    }
  }

  Future<void> _pullLogs(String token) async {
    final cursor = await _syncState.readDeviceLogsCreatedSince();
    final remote = await _remote.listDeviceLogs(
      token: token,
      createdSince: cursor,
    );
    DateTime? maxCreated = cursor;
    for (final row in remote) {
      await mergeLogAppendOnly(localStore: _logs, remote: row);
      final created = row.createdAt.toUtc();
      if (maxCreated == null || created.isAfter(maxCreated)) {
        maxCreated = created;
      }
    }
    if (maxCreated != null &&
        (cursor == null || maxCreated.isAfter(cursor.toUtc()))) {
      await _syncState.writeDeviceLogsCreatedSince(maxCreated);
    }
  }

  Future<void> _pullBirthdays(String token) async {
    final cursor = await _syncState.readBirthdaysUpdatedSince();
    final remote = await _remote.listBirthdays(
      token: token,
      updatedSince: cursor,
    );
    DateTime? maxUpdated = cursor;
    for (final row in remote) {
      await mergeBirthdayLocalWins(localStore: _birthdays, remote: row);
      final updated = row.updatedAt.toUtc();
      if (maxUpdated == null || updated.isAfter(maxUpdated)) {
        maxUpdated = updated;
      }
    }
    if (maxUpdated != null &&
        (cursor == null || maxUpdated.isAfter(cursor.toUtc()))) {
      await _syncState.writeBirthdaysUpdatedSince(maxUpdated);
    }
  }

  Future<void> _pullTags(String token) async {
    final cursor = await _syncState.readTagsUpdatedSince();
    final remote = await _remote.listTags(token: token, updatedSince: cursor);
    DateTime? maxUpdated = cursor;
    for (final row in remote) {
      await mergeTagLocalWins(localStore: _tags, remote: row);
      final updated = row.updatedAt.toUtc();
      if (maxUpdated == null || updated.isAfter(maxUpdated)) {
        maxUpdated = updated;
      }
    }
    if (maxUpdated != null &&
        (cursor == null || maxUpdated.isAfter(cursor.toUtc()))) {
      await _syncState.writeTagsUpdatedSince(maxUpdated);
    }
  }

  Future<void> _pullDeviceTagLinks(String token) async {
    final cursor = await _syncState.readDeviceTagLinksCreatedSince();
    final remote = await _remote.listDeviceTagLinks(
      token: token,
      createdSince: cursor,
    );
    DateTime? maxCreated = cursor;
    for (final row in remote) {
      await mergeLinkAppendOnly(localStore: _tags, remote: row);
      final created = row.createdAt.toUtc();
      if (maxCreated == null || created.isAfter(maxCreated)) {
        maxCreated = created;
      }
    }
    if (maxCreated != null &&
        (cursor == null || maxCreated.isAfter(cursor.toUtc()))) {
      await _syncState.writeDeviceTagLinksCreatedSince(maxCreated);
    }
  }
}

String _linkKey(String deviceId, String tagId) => '$deviceId\u0000$tagId';

/// Sync-relevant equality: all wire fields except timestamps.
bool devicesMeaningfullyEqual(DeviceModel a, DeviceModel b) {
  return _syncPayloadEqual(a.toSyncJson(), b.toSyncJson());
}

bool birthdaysMeaningfullyEqual(BirthdayModel a, BirthdayModel b) {
  return _syncPayloadEqual(a.toSyncJson(), b.toSyncJson());
}

bool tagsMeaningfullyEqual(TagModel a, TagModel b) {
  return _syncPayloadEqual(a.toSyncJson(), b.toSyncJson());
}

bool _syncPayloadEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
  final left = Map<String, dynamic>.from(a)
    ..remove('updated_at')
    ..remove('created_at');
  final right = Map<String, dynamic>.from(b)
    ..remove('updated_at')
    ..remove('created_at');
  return jsonEncode(left) == jsonEncode(right);
}

/// Stamp that is strictly after [remote] so server LWW accepts local.
DateTime syncBumpUpdatedAt(DateTime local, DateTime remote) {
  final now = DateTime.now().toUtc();
  final minNeeded = remote.toUtc().add(const Duration(seconds: 1));
  if (now.isAfter(minNeeded) && now.isAfter(local.toUtc())) {
    return now;
  }
  final afterLocal = local.toUtc().add(const Duration(seconds: 1));
  return minNeeded.isAfter(afterLocal) ? minNeeded : afterLocal;
}

DeviceModel deviceWithUpdatedAt(DeviceModel device, DateTime updatedAt) {
  return DeviceModel(
    id: device.id,
    parentId: device.parentId,
    name: device.name,
    description: device.description,
    categoryPreset: device.categoryPreset,
    locationLabel: device.locationLabel,
    status: device.status,
    usageUnit: device.usageUnit,
    currentUsage: device.currentUsage,
    scheduleType: device.scheduleType,
    intervalValue: device.intervalValue,
    intervalUnit: device.intervalUnit,
    fixedDueAt: device.fixedDueAt,
    lastMaintainedAt: device.lastMaintainedAt,
    usageAtLastMaintenance: device.usageAtLastMaintenance,
    createdAt: device.createdAt,
    updatedAt: updatedAt,
  );
}

BirthdayModel birthdayWithUpdatedAt(
  BirthdayModel birthday,
  DateTime updatedAt,
) {
  return BirthdayModel(
    id: birthday.id,
    name: birthday.name,
    birthMonth: birthday.birthMonth,
    birthDay: birthday.birthDay,
    calendarSystem: birthday.calendarSystem,
    createdAt: birthday.createdAt,
    updatedAt: updatedAt,
  );
}

TagModel tagWithUpdatedAt(TagModel tag, DateTime updatedAt) {
  return TagModel(
    id: tag.id,
    name: tag.name,
    createdAt: tag.createdAt,
    updatedAt: updatedAt,
  );
}

/// Keep local when id exists; insert remote only when missing (additive).
Future<void> mergeDeviceLocalWins({
  required DeviceLocalDataSource localStore,
  required DeviceModel remote,
}) async {
  final local = await localStore.getDevice(remote.id);
  if (local != null) return;
  await localStore.upsertDevice(remote);
}

/// Append-only: insert remote only when id is missing locally.
/// Does not apply device log side effects (devices are SoT after sync).
Future<void> mergeLogAppendOnly({
  required DeviceLogLocalDataSource localStore,
  required DeviceLogModel remote,
}) async {
  final existing = await localStore.getLogById(remote.id);
  if (existing != null) return;
  await localStore.upsertDeviceLog(remote);
}

/// Keep local when id exists; insert remote only when missing (additive).
Future<void> mergeBirthdayLocalWins({
  required BirthdayLocalDataSource localStore,
  required BirthdayModel remote,
}) async {
  final local = await localStore.getBirthday(remote.id);
  if (local != null) return;
  await localStore.upsertBirthday(remote);
}

/// Keep local when id exists; insert remote only when missing (additive).
Future<void> mergeTagLocalWins({
  required TagLocalDataSource localStore,
  required TagModel remote,
}) async {
  final local = await localStore.getTag(remote.id);
  if (local != null) return;
  await localStore.upsertTag(remote);
}

/// Append-only: insert remote link only when the pair is missing locally.
Future<void> mergeLinkAppendOnly({
  required TagLocalDataSource localStore,
  required DeviceTagLinkModel remote,
}) async {
  final existing = await localStore.getDeviceTagLink(
    remote.deviceId,
    remote.tagId,
  );
  if (existing != null) return;
  await localStore.upsertDeviceTagLink(remote);
}
