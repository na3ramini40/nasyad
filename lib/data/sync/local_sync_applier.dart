import 'package:nasyad/data/datasources/birthday_local_datasource.dart';
import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/models/birthday_model.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/sync/sync_payload_codec.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/sync/sync_entity_kind.dart';
import 'package:nasyad/domain/sync/sync_mutation.dart';

/// Applies remote mutations into Drift using last-write-wins on [updatedAt].
class LocalSyncApplier {
  LocalSyncApplier({
    required AppDatabase db,
    required DeviceLocalDataSource devices,
    required DeviceLogLocalDataSource logs,
    required BirthdayLocalDataSource birthdays,
  }) : _db = db,
       _devices = devices,
       _logs = logs,
       _birthdays = birthdays;

  final AppDatabase _db;
  final DeviceLocalDataSource _devices;
  final DeviceLogLocalDataSource _logs;
  final BirthdayLocalDataSource _birthdays;

  Future<void> apply(SyncMutation mutation) async {
    switch (mutation.entityKind) {
      case SyncEntityKind.device:
        await _applyDevice(mutation);
      case SyncEntityKind.deviceLog:
        await _applyDeviceLog(mutation);
      case SyncEntityKind.birthday:
        await _applyBirthday(mutation);
    }
  }

  Future<void> _applyDevice(SyncMutation mutation) async {
    if (mutation.operation == SyncOperation.delete) {
      await _devices.setDeviceStatus(
        mutation.entityId,
        DeviceStatus.archived.storageValue,
        DateTime.now(),
      );
      return;
    }

    final incoming = SyncPayloadCodec.deviceFromPayload(mutation.payload);
    final existing = await _devices.getDevice(incoming.id);
    if (existing != null &&
        existing.updatedAt.isAfter(incoming.updatedAt)) {
      return;
    }
    await _devices.upsertDevice(DeviceModel.fromEntity(incoming));
  }

  Future<void> _applyDeviceLog(SyncMutation mutation) async {
    if (mutation.operation == SyncOperation.delete) {
      await _logs.deleteDeviceLog(mutation.entityId);
      return;
    }

    final incoming = SyncPayloadCodec.deviceLogFromPayload(mutation.payload);
    final existing = await _logs.getLogById(incoming.id);
    if (existing != null && existing.createdAt.isAfter(incoming.createdAt)) {
      return;
    }
    await _logs.upsertDeviceLog(DeviceLogModel.fromEntity(incoming));
  }

  Future<void> _applyBirthday(SyncMutation mutation) async {
    if (mutation.operation == SyncOperation.delete) {
      await _birthdays.deleteBirthday(mutation.entityId);
      return;
    }

    final incoming = SyncPayloadCodec.birthdayFromPayload(mutation.payload);
    final existing = await _birthdays.getBirthday(incoming.id);
    if (existing != null &&
        existing.updatedAt.isAfter(incoming.updatedAt)) {
      return;
    }
    final model = BirthdayModel.fromEntity(incoming);
    if (existing == null) {
      await _birthdays.insertBirthday(model);
    } else {
      await _birthdays.updateBirthday(model);
    }
  }

  Future<void> applyImportBundle({
    required Iterable<Device> devices,
    required Iterable<DeviceLog> logs,
    required Iterable<Birthday> birthdays,
  }) {
    return _db.transaction(() async {
      for (final device in devices) {
        await _devices.upsertDevice(DeviceModel.fromEntity(device));
      }
      for (final log in logs) {
        await _logs.upsertDeviceLog(DeviceLogModel.fromEntity(log));
      }
      for (final birthday in birthdays) {
        final model = BirthdayModel.fromEntity(birthday);
        final existing = await _birthdays.getBirthday(birthday.id);
        if (existing == null) {
          await _birthdays.insertBirthday(model);
        } else {
          await _birthdays.updateBirthday(model);
        }
      }
    });
  }
}
