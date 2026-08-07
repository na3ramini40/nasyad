import 'dart:convert';

import 'package:nasyad/data/models/birthday_model.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/sync/sync_entity_kind.dart';
import 'package:nasyad/domain/sync/sync_mutation.dart';

/// JSON mapping between domain entities and remote row payloads.
class SyncPayloadCodec {
  static String encode(Map<String, dynamic> payload) {
    return jsonEncode(payload);
  }

  static Map<String, dynamic> decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Sync payload must be a JSON object');
    }
    return decoded;
  }

  static SyncMutation deviceUpsert(Device device) {
    final model = DeviceModel.fromEntity(device);
    return SyncMutation(
      id: _outboxId(SyncEntityKind.device, device.id),
      entityKind: SyncEntityKind.device,
      operation: SyncOperation.upsert,
      entityId: device.id,
      payload: _devicePayload(model),
      createdAt: DateTime.now(),
    );
  }

  static SyncMutation deviceLogUpsert(DeviceLog log) {
    final model = DeviceLogModel.fromEntity(log);
    return SyncMutation(
      id: _outboxId(SyncEntityKind.deviceLog, log.id),
      entityKind: SyncEntityKind.deviceLog,
      operation: SyncOperation.upsert,
      entityId: log.id,
      payload: _deviceLogPayload(model),
      createdAt: DateTime.now(),
    );
  }

  static SyncMutation deviceLogDelete(String id) {
    return SyncMutation(
      id: _outboxId(SyncEntityKind.deviceLog, id, SyncOperation.delete),
      entityKind: SyncEntityKind.deviceLog,
      operation: SyncOperation.delete,
      entityId: id,
      payload: {'id': id},
      createdAt: DateTime.now(),
    );
  }

  static SyncMutation birthdayUpsert(Birthday birthday) {
    final model = BirthdayModel.fromEntity(birthday);
    return SyncMutation(
      id: _outboxId(SyncEntityKind.birthday, birthday.id),
      entityKind: SyncEntityKind.birthday,
      operation: SyncOperation.upsert,
      entityId: birthday.id,
      payload: _birthdayPayload(model),
      createdAt: DateTime.now(),
    );
  }

  static SyncMutation birthdayDelete(String id) {
    return SyncMutation(
      id: _outboxId(SyncEntityKind.birthday, id, SyncOperation.delete),
      entityKind: SyncEntityKind.birthday,
      operation: SyncOperation.delete,
      entityId: id,
      payload: {'id': id},
      createdAt: DateTime.now(),
    );
  }

  static Device deviceFromPayload(Map<String, dynamic> payload) {
    return DeviceModel(
      id: payload['id'] as String,
      parentId: payload['parent_id'] as String?,
      name: payload['name'] as String,
      description: payload['description'] as String?,
      status: DeviceStatusX.fromStorage(payload['status'] as String),
      usageUnit: payload['usage_unit'] == null
          ? null
          : UsageIntervalUnitX.fromStorage(payload['usage_unit'] as String),
      currentUsage: payload['current_usage'] as int,
      scheduleType: payload['schedule_type'] == null
          ? null
          : ScheduleTypeX.fromStorage(payload['schedule_type'] as String),
      intervalValue: payload['interval_value'] as int?,
      intervalUnit: payload['interval_unit'] as String?,
      fixedDueAt: _readDateTime(payload['fixed_due_at']),
      lastMaintainedAt: _readDateTime(payload['last_maintained_at']),
      usageAtLastMaintenance: payload['usage_at_last_maintenance'] as int,
      createdAt: _readDateTime(payload['created_at'])!,
      updatedAt: _readDateTime(payload['updated_at'])!,
    ).toEntity();
  }

  static DeviceLog deviceLogFromPayload(Map<String, dynamic> payload) {
    return DeviceLogModel(
      id: payload['id'] as String,
      deviceId: payload['device_id'] as String,
      date: _readDateTime(payload['date'])!,
      notes: payload['notes'] as String?,
      kind: DeviceLogKindX.fromStorage(payload['kind'] as String),
      usageValue: payload['usage_value'] as int?,
      usageUnit: payload['usage_unit'] == null
          ? null
          : UsageIntervalUnitX.fromStorage(payload['usage_unit'] as String),
      createdAt: _readDateTime(payload['created_at'])!,
    ).toEntity();
  }

  static Birthday birthdayFromPayload(Map<String, dynamic> payload) {
    return BirthdayModel(
      id: payload['id'] as String,
      name: payload['name'] as String,
      birthMonth: payload['birth_month'] as int,
      birthDay: payload['birth_day'] as int,
      calendarSystem: CalendarSystem.fromStorage(
        payload['calendar_system'] as String,
      ),
      createdAt: _readDateTime(payload['created_at'])!,
      updatedAt: _readDateTime(payload['updated_at'])!,
    ).toEntity();
  }

  static Map<String, dynamic> _devicePayload(DeviceModel model) {
    return {
      'id': model.id,
      'parent_id': model.parentId,
      'name': model.name,
      'description': model.description,
      'status': model.status.storageValue,
      'usage_unit': model.usageUnit?.storageValue,
      'current_usage': model.currentUsage,
      'schedule_type': model.scheduleType?.storageValue,
      'interval_value': model.intervalValue,
      'interval_unit': model.intervalUnit,
      'fixed_due_at': model.fixedDueAt?.toUtc().toIso8601String(),
      'last_maintained_at': model.lastMaintainedAt?.toUtc().toIso8601String(),
      'usage_at_last_maintenance': model.usageAtLastMaintenance,
      'created_at': model.createdAt.toUtc().toIso8601String(),
      'updated_at': model.updatedAt.toUtc().toIso8601String(),
    };
  }

  static Map<String, dynamic> _deviceLogPayload(DeviceLogModel model) {
    return {
      'id': model.id,
      'device_id': model.deviceId,
      'date': model.date.toUtc().toIso8601String(),
      'notes': model.notes,
      'kind': model.kind.storageValue,
      'usage_value': model.usageValue,
      'usage_unit': model.usageUnit?.storageValue,
      'created_at': model.createdAt.toUtc().toIso8601String(),
    };
  }

  static Map<String, dynamic> _birthdayPayload(BirthdayModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'birth_month': model.birthMonth,
      'birth_day': model.birthDay,
      'calendar_system': model.calendarSystem.storageValue,
      'created_at': model.createdAt.toUtc().toIso8601String(),
      'updated_at': model.updatedAt.toUtc().toIso8601String(),
    };
  }

  static String _outboxId(
    SyncEntityKind kind,
    String entityId, [
    SyncOperation operation = SyncOperation.upsert,
  ]) {
    return '${kind.storageValue}:$entityId:${operation.storageValue}';
  }

  static DateTime? _readDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String).toLocal();
  }
}
