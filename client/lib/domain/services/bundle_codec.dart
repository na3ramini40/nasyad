import 'dart:convert';

import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';
import 'package:nasyad/domain/entities/device_category_preset.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class BundleCodecException implements Exception {
  BundleCodecException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract final class BundleCodec {
  static String encode(ExportBundle bundle, ExportFormat format) {
    return switch (format) {
      ExportFormat.json => encodeJson(bundle),
      ExportFormat.csv => encodeCsv(bundle),
      ExportFormat.plainText => encodePlainText(bundle),
    };
  }

  static ExportBundle decode(String content, {ExportFormat? format}) {
    final detected = format ?? detectFormat(content);
    return switch (detected) {
      ExportFormat.json => decodeJson(content),
      ExportFormat.csv => decodeCsv(content),
      ExportFormat.plainText => decodePlainText(content),
    };
  }

  static ExportFormat detectFormat(String content) {
    final trimmed = content.trimLeft();
    if (trimmed.startsWith('{')) return ExportFormat.json;
    if (trimmed.startsWith('#devices') ||
        trimmed.startsWith('# devices') ||
        trimmed.startsWith('#birthdays') ||
        trimmed.startsWith('# birthdays') ||
        trimmed.startsWith('#places') ||
        trimmed.startsWith('# places')) {
      return ExportFormat.csv;
    }
    if (trimmed.startsWith('Nasyad export') ||
        trimmed.startsWith('Device') ||
        trimmed.startsWith('Birthday') ||
        trimmed.startsWith('Place')) {
      return ExportFormat.plainText;
    }
    if (trimmed.contains('#devices') ||
        trimmed.contains('#rules') ||
        trimmed.contains('#birthdays') ||
        trimmed.contains('#places') ||
        trimmed.contains('#logs')) {
      return ExportFormat.csv;
    }
    throw BundleCodecException('Unable to detect export format');
  }

  static bool isSupportedVersion(int version) =>
      version >= 1 && version <= ExportBundle.currentVersion;

  static ExportFormat? formatFromExtension(String? pathOrName) {
    if (pathOrName == null) return null;
    final lower = pathOrName.toLowerCase();
    if (lower.endsWith('.json')) return ExportFormat.json;
    if (lower.endsWith('.csv')) return ExportFormat.csv;
    if (lower.endsWith('.txt')) return ExportFormat.plainText;
    return null;
  }

  static String encodeJson(ExportBundle bundle) {
    final map = {
      'format': bundle.format,
      'version': bundle.version,
      'exportedAt': bundle.exportedAt.toUtc().toIso8601String(),
      'devices': bundle.devices.map(_deviceBundleToJson).toList(),
      'birthdays': bundle.birthdays.map(_birthdayToJson).toList(),
      'places': bundle.places.map(_placeToJson).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static ExportBundle decodeJson(String content) {
    final dynamic raw;
    try {
      raw = jsonDecode(content);
    } on FormatException catch (e) {
      throw BundleCodecException('Invalid JSON: ${e.message}');
    }
    if (raw is! Map<String, dynamic>) {
      throw BundleCodecException('JSON root must be an object');
    }
    final format = raw['format'] as String? ?? ExportBundle.formatName;
    if (format != ExportBundle.formatName) {
      throw BundleCodecException('Unsupported format: $format');
    }
    final version = raw['version'] as int? ?? 1;
    if (!isSupportedVersion(version)) {
      throw BundleCodecException('Unsupported version: $version');
    }
    final exportedAt = _parseDate(raw['exportedAt']) ?? DateTime.now().toUtc();
    final devicesRaw = raw['devices'];
    if (devicesRaw is! List) {
      throw BundleCodecException('devices must be a list');
    }
    final devices = devicesRaw
        .map((e) => _deviceBundleFromJson(e as Map<String, dynamic>))
        .toList();
    final birthdaysRaw = raw['birthdays'];
    final birthdays = birthdaysRaw is List
        ? birthdaysRaw
              .map((e) => _birthdayFromJson(e as Map<String, dynamic>))
              .toList()
        : <Birthday>[];
    final placesRaw = raw['places'];
    final places = placesRaw is List
        ? placesRaw
              .map((e) => _placeFromJson(e as Map<String, dynamic>))
              .toList()
        : <Place>[];
    return ExportBundle(
      format: format,
      version: ExportBundle.currentVersion,
      exportedAt: exportedAt,
      devices: devices,
      birthdays: birthdays,
      places: places,
    );
  }

  static String encodeCsv(ExportBundle bundle) {
    final buffer = StringBuffer();
    buffer.writeln('#devices');
    buffer.writeln(
      _csvRow([
        'id',
        'parentId',
        'name',
        'description',
        'categoryPreset',
        'locationLabel',
        'status',
        'usageUnit',
        'currentUsage',
        'scheduleType',
        'intervalValue',
        'intervalUnit',
        'fixedDueAt',
        'lastMaintainedAt',
        'usageAtLastMaintenance',
        'createdAt',
        'updatedAt',
      ]),
    );
    for (final d in bundle.devices) {
      final device = d.device;
      buffer.writeln(
        _csvRow([
          device.id,
          device.parentId ?? '',
          device.name,
          device.description ?? '',
          device.categoryPreset?.storageValue ?? '',
          device.locationLabel ?? '',
          device.status.storageValue,
          device.usageUnit?.storageValue ?? '',
          '${device.currentUsage}',
          device.scheduleType?.storageValue ?? '',
          device.intervalValue?.toString() ?? '',
          device.intervalUnit ?? '',
          device.fixedDueAt?.toUtc().toIso8601String() ?? '',
          device.lastMaintainedAt?.toUtc().toIso8601String() ?? '',
          '${device.usageAtLastMaintenance}',
          device.createdAt.toUtc().toIso8601String(),
          device.updatedAt.toUtc().toIso8601String(),
        ]),
      );
    }

    buffer.writeln('#logs');
    buffer.writeln(
      _csvRow([
        'id',
        'deviceId',
        'date',
        'notes',
        'kind',
        'usageValue',
        'usageUnit',
        'cost',
        'costCurrency',
        'vendor',
        'photoBase64',
        'createdAt',
      ]),
    );
    for (final d in bundle.devices) {
      for (final log in d.logs) {
        buffer.writeln(
          _csvRow([
            log.id,
            log.deviceId,
            log.date.toUtc().toIso8601String(),
            log.notes ?? '',
            log.kind.storageValue,
            log.usageValue?.toString() ?? '',
            log.usageUnit?.storageValue ?? '',
            log.cost?.toString() ?? '',
            log.costCurrency ?? '',
            log.vendor ?? '',
            log.photoBase64 ?? '',
            log.createdAt.toUtc().toIso8601String(),
          ]),
        );
      }
    }

    buffer.writeln('#birthdays');
    buffer.writeln(
      _csvRow([
        'id',
        'name',
        'birthMonth',
        'birthDay',
        'calendarSystem',
        'createdAt',
        'updatedAt',
      ]),
    );
    for (final birthday in bundle.birthdays) {
      buffer.writeln(
        _csvRow([
          birthday.id,
          birthday.name,
          '${birthday.birthMonth}',
          '${birthday.birthDay}',
          birthday.calendarSystem.storageValue,
          birthday.createdAt.toUtc().toIso8601String(),
          birthday.updatedAt.toUtc().toIso8601String(),
        ]),
      );
    }

    buffer.writeln('#places');
    buffer.writeln(
      _csvRow([
        'id',
        'name',
        'kind',
        'pointsJson',
        'notes',
        'createdAt',
        'updatedAt',
      ]),
    );
    for (final place in bundle.places) {
      buffer.writeln(
        _csvRow([
          place.id,
          place.name,
          place.kind.storageValue,
          _encodePointsJson(place.points),
          place.notes ?? '',
          place.createdAt.toUtc().toIso8601String(),
          place.updatedAt.toUtc().toIso8601String(),
        ]),
      );
    }

    return buffer.toString();
  }

  static ExportBundle decodeCsv(String content) {
    final lines = content
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final devices = <String, Device>{};
    final scheduleByDevice = <String, Map<String, String>>{};
    final logsByDevice = <String, List<DeviceLog>>{};
    final birthdays = <Birthday>[];
    final places = <Place>[];

    String? section;
    List<String>? headers;

    for (final line in lines) {
      if (line.startsWith('#')) {
        section = line.replaceFirst('#', '').trim().toLowerCase();
        headers = null;
        continue;
      }
      final cells = _parseCsvLine(line);
      if (headers == null) {
        headers = cells;
        continue;
      }
      final row = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        row[headers[i]] = i < cells.length ? cells[i] : '';
      }

      switch (section) {
        case 'devices':
          final device = _deviceFromMap(row);
          devices[device.id] = device;
        case 'rules':
          final deviceId = row['deviceId']?.trim() ?? '';
          if (deviceId.isNotEmpty && !scheduleByDevice.containsKey(deviceId)) {
            scheduleByDevice[deviceId] = row;
          }
        case 'logs':
          final log = _logFromMap(row);
          logsByDevice.putIfAbsent(log.deviceId, () => []).add(log);
        case 'birthdays':
          birthdays.add(_birthdayFromMap(row));
        case 'places':
          places.add(_placeFromMap(row));
        default:
          throw BundleCodecException('Unknown CSV section: $section');
      }
    }

    if (devices.isEmpty && birthdays.isEmpty && places.isEmpty) {
      throw BundleCodecException('CSV contains no transferable data');
    }

    return ExportBundle(
      exportedAt: DateTime.now().toUtc(),
      devices: devices.values.map((device) {
        final merged = _mergeLegacyRule(device, scheduleByDevice[device.id]);
        return ExportDeviceBundle(
          device: merged,
          logs: logsByDevice[device.id] ?? const [],
        );
      }).toList(),
      birthdays: birthdays,
      places: places,
    );
  }

  static String encodePlainText(ExportBundle bundle) {
    final buffer = StringBuffer();
    buffer.writeln('Nasyad export');
    buffer.writeln('format: ${bundle.format}');
    buffer.writeln('version: ${bundle.version}');
    buffer.writeln(
      'exportedAt: ${bundle.exportedAt.toUtc().toIso8601String()}',
    );
    buffer.writeln();

    for (final d in bundle.devices) {
      final device = d.device;
      buffer.writeln('Device');
      buffer.writeln('id: ${device.id}');
      buffer.writeln('parentId: ${device.parentId ?? ''}');
      buffer.writeln('name: ${device.name}');
      buffer.writeln('description: ${device.description ?? ''}');
      buffer.writeln(
        'categoryPreset: ${device.categoryPreset?.storageValue ?? ''}',
      );
      buffer.writeln('locationLabel: ${device.locationLabel ?? ''}');
      buffer.writeln('status: ${device.status.storageValue}');
      buffer.writeln('usageUnit: ${device.usageUnit?.storageValue ?? ''}');
      buffer.writeln('currentUsage: ${device.currentUsage}');
      buffer.writeln(
        'scheduleType: ${device.scheduleType?.storageValue ?? ''}',
      );
      buffer.writeln('intervalValue: ${device.intervalValue ?? ''}');
      buffer.writeln('intervalUnit: ${device.intervalUnit ?? ''}');
      buffer.writeln(
        'fixedDueAt: ${device.fixedDueAt?.toUtc().toIso8601String() ?? ''}',
      );
      buffer.writeln(
        'lastMaintainedAt: ${device.lastMaintainedAt?.toUtc().toIso8601String() ?? ''}',
      );
      buffer.writeln(
        'usageAtLastMaintenance: ${device.usageAtLastMaintenance}',
      );
      buffer.writeln(
        'createdAt: ${device.createdAt.toUtc().toIso8601String()}',
      );
      buffer.writeln(
        'updatedAt: ${device.updatedAt.toUtc().toIso8601String()}',
      );
      buffer.writeln();

      for (final log in d.logs) {
        buffer.writeln('Log');
        buffer.writeln('id: ${log.id}');
        buffer.writeln('deviceId: ${log.deviceId}');
        buffer.writeln('date: ${log.date.toUtc().toIso8601String()}');
        buffer.writeln('notes: ${log.notes ?? ''}');
        buffer.writeln('kind: ${log.kind.storageValue}');
        buffer.writeln('usageValue: ${log.usageValue ?? ''}');
        buffer.writeln('usageUnit: ${log.usageUnit?.storageValue ?? ''}');
        buffer.writeln('cost: ${log.cost ?? ''}');
        buffer.writeln('costCurrency: ${log.costCurrency ?? ''}');
        buffer.writeln('vendor: ${log.vendor ?? ''}');
        if (log.photoBase64 != null && log.photoBase64!.isNotEmpty) {
          buffer.writeln('photoBase64: ${log.photoBase64}');
        }
        buffer.writeln('createdAt: ${log.createdAt.toUtc().toIso8601String()}');
        buffer.writeln();
      }
    }

    for (final birthday in bundle.birthdays) {
      buffer.writeln('Birthday');
      buffer.writeln('id: ${birthday.id}');
      buffer.writeln('name: ${birthday.name}');
      buffer.writeln('birthMonth: ${birthday.birthMonth}');
      buffer.writeln('birthDay: ${birthday.birthDay}');
      buffer.writeln('calendarSystem: ${birthday.calendarSystem.storageValue}');
      buffer.writeln(
        'createdAt: ${birthday.createdAt.toUtc().toIso8601String()}',
      );
      buffer.writeln(
        'updatedAt: ${birthday.updatedAt.toUtc().toIso8601String()}',
      );
      buffer.writeln();
    }

    for (final place in bundle.places) {
      buffer.writeln('Place');
      buffer.writeln('id: ${place.id}');
      buffer.writeln('name: ${place.name}');
      buffer.writeln('kind: ${place.kind.storageValue}');
      buffer.writeln('pointsJson: ${_encodePointsJson(place.points)}');
      buffer.writeln('notes: ${place.notes ?? ''}');
      buffer.writeln('createdAt: ${place.createdAt.toUtc().toIso8601String()}');
      buffer.writeln('updatedAt: ${place.updatedAt.toUtc().toIso8601String()}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  static ExportBundle decodePlainText(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    final devices = <String, Device>{};
    final scheduleByDevice = <String, Map<String, String>>{};
    final logsByDevice = <String, List<DeviceLog>>{};
    final birthdays = <Birthday>[];
    final places = <Place>[];

    String? blockType;
    final fields = <String, String>{};

    void flush() {
      if (blockType == null || fields.isEmpty) {
        fields.clear();
        blockType = null;
        return;
      }
      switch (blockType) {
        case 'Device':
          final device = _deviceFromMap(fields);
          devices[device.id] = device;
        case 'Rule':
          final deviceId = fields['deviceId']?.trim() ?? '';
          if (deviceId.isNotEmpty && !scheduleByDevice.containsKey(deviceId)) {
            scheduleByDevice[deviceId] = Map<String, String>.from(fields);
          }
        case 'Log':
          final log = _logFromMap(fields);
          logsByDevice.putIfAbsent(log.deviceId, () => []).add(log);
        case 'Birthday':
          birthdays.add(_birthdayFromMap(fields));
        case 'Place':
          places.add(_placeFromMap(fields));
      }
      fields.clear();
      blockType = null;
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        flush();
        continue;
      }
      if (trimmed == 'Device' ||
          trimmed == 'Rule' ||
          trimmed == 'Log' ||
          trimmed == 'Birthday' ||
          trimmed == 'Place') {
        flush();
        blockType = trimmed;
        continue;
      }
      if (trimmed.startsWith('Nasyad export') ||
          trimmed.startsWith('format:') ||
          trimmed.startsWith('version:') ||
          trimmed.startsWith('exportedAt:')) {
        continue;
      }
      final colon = trimmed.indexOf(':');
      if (colon <= 0 || blockType == null) continue;
      final key = trimmed.substring(0, colon).trim();
      final value = trimmed.substring(colon + 1).trim();
      fields[key] = value;
    }
    flush();

    if (devices.isEmpty && birthdays.isEmpty && places.isEmpty) {
      throw BundleCodecException('Plain text contains no transferable data');
    }

    return ExportBundle(
      exportedAt: DateTime.now().toUtc(),
      devices: devices.values.map((device) {
        final merged = _mergeLegacyRule(device, scheduleByDevice[device.id]);
        return ExportDeviceBundle(
          device: merged,
          logs: logsByDevice[device.id] ?? const [],
        );
      }).toList(),
      birthdays: birthdays,
      places: places,
    );
  }

  static Map<String, dynamic> _deviceBundleToJson(ExportDeviceBundle d) {
    final device = d.device;
    return {
      'id': device.id,
      'parentId': device.parentId,
      'name': device.name,
      'description': device.description,
      'categoryPreset': device.categoryPreset?.storageValue,
      'locationLabel': device.locationLabel,
      'status': device.status.storageValue,
      'usageUnit': device.usageUnit?.storageValue,
      'currentUsage': device.currentUsage,
      'scheduleType': device.scheduleType?.storageValue,
      'intervalValue': device.intervalValue,
      'intervalUnit': device.intervalUnit,
      'fixedDueAt': device.fixedDueAt?.toUtc().toIso8601String(),
      'lastMaintainedAt': device.lastMaintainedAt?.toUtc().toIso8601String(),
      'usageAtLastMaintenance': device.usageAtLastMaintenance,
      'createdAt': device.createdAt.toUtc().toIso8601String(),
      'updatedAt': device.updatedAt.toUtc().toIso8601String(),
      'logs': d.logs.map(_logToJson).toList(),
    };
  }

  static ExportDeviceBundle _deviceBundleFromJson(Map<String, dynamic> json) {
    var device = _deviceFromMap({
      'id': '${json['id']}',
      'parentId': json['parentId']?.toString() ?? '',
      'name': '${json['name']}',
      'description': json['description']?.toString() ?? '',
      'categoryPreset': json['categoryPreset']?.toString() ?? '',
      'locationLabel': json['locationLabel']?.toString() ?? '',
      'status': '${json['status'] ?? 'active'}',
      'usageUnit': json['usageUnit']?.toString() ?? '',
      'currentUsage': '${json['currentUsage'] ?? 0}',
      'scheduleType': json['scheduleType']?.toString() ?? '',
      'intervalValue': json['intervalValue']?.toString() ?? '',
      'intervalUnit': json['intervalUnit']?.toString() ?? '',
      'fixedDueAt': json['fixedDueAt']?.toString() ?? '',
      'lastMaintainedAt': json['lastMaintainedAt']?.toString() ?? '',
      'usageAtLastMaintenance': '${json['usageAtLastMaintenance'] ?? 0}',
      'createdAt': '${json['createdAt']}',
      'updatedAt': '${json['updatedAt']}',
    });

    final rulesRaw = json['rules'];
    if (!device.hasSchedule && rulesRaw is List && rulesRaw.isNotEmpty) {
      final first = rulesRaw.first as Map<String, dynamic>;
      device = _mergeLegacyRule(device, {
        'scheduleType': first['scheduleType']?.toString() ?? '',
        'intervalValue': first['intervalValue']?.toString() ?? '',
        'intervalUnit': first['intervalUnit']?.toString() ?? '',
        'fixedDueAt': first['fixedDueAt']?.toString() ?? '',
      });
    }

    final logsRaw = json['logs'];
    final logs = logsRaw is List
        ? logsRaw.map((e) => _logFromJson(e as Map<String, dynamic>)).toList()
        : <DeviceLog>[];
    return ExportDeviceBundle(device: device, logs: logs);
  }

  static Map<String, dynamic> _logToJson(DeviceLog log) => {
    'id': log.id,
    'deviceId': log.deviceId,
    'date': log.date.toUtc().toIso8601String(),
    'notes': log.notes,
    'kind': log.kind.storageValue,
    'usageValue': log.usageValue,
    'usageUnit': log.usageUnit?.storageValue,
    if (log.cost != null) 'cost': log.cost,
    if (log.costCurrency != null) 'costCurrency': log.costCurrency,
    if (log.vendor != null) 'vendor': log.vendor,
    if (log.photoBase64 != null && log.photoBase64!.isNotEmpty)
      'photoBase64': log.photoBase64,
    'createdAt': log.createdAt.toUtc().toIso8601String(),
  };

  static DeviceLog _logFromJson(Map<String, dynamic> json) => _logFromMap({
    'id': '${json['id']}',
    'deviceId': '${json['deviceId']}',
    'date': '${json['date']}',
    'notes': json['notes']?.toString() ?? '',
    'kind': json['kind']?.toString() ?? '',
    'usageValue':
        json['usageValue']?.toString() ?? json['usageDelta']?.toString() ?? '',
    'usageUnit': json['usageUnit']?.toString() ?? '',
    'cost': json['cost']?.toString() ?? '',
    'costCurrency': json['costCurrency']?.toString() ?? '',
    'vendor': json['vendor']?.toString() ?? '',
    'photoBase64': json['photoBase64']?.toString() ?? '',
    'createdAt': '${json['createdAt']}',
  });

  static Device _mergeLegacyRule(Device device, Map<String, String>? rule) {
    if (rule == null || device.hasSchedule) return device;
    final typeRaw = rule['scheduleType']?.trim() ?? '';
    if (typeRaw.isEmpty) return device;
    final intervalRaw = rule['intervalValue']?.trim() ?? '';
    final unitRaw = rule['intervalUnit']?.trim() ?? '';
    final scheduleType = ScheduleTypeX.fromStorage(typeRaw);
    final usageUnit =
        unitRaw.isNotEmpty &&
            UsageIntervalUnit.values.any((u) => u.name == unitRaw)
        ? UsageIntervalUnitX.fromStorage(unitRaw)
        : device.usageUnit;
    return device.copyWith(
      scheduleType: scheduleType,
      intervalValue: intervalRaw.isEmpty ? null : int.tryParse(intervalRaw),
      intervalUnit: unitRaw.isEmpty ? null : unitRaw,
      fixedDueAt: _parseDate(rule['fixedDueAt']),
      usageUnit: usageUnit,
      lastMaintainedAt: device.lastMaintainedAt ?? device.createdAt,
    );
  }

  static Device _deviceFromMap(Map<String, String> map) {
    final id = map['id']?.trim() ?? '';
    final name = map['name']?.trim() ?? '';
    if (id.isEmpty || name.isEmpty) {
      throw BundleCodecException('Device requires id and name');
    }
    final createdAt = _parseDate(map['createdAt']);
    final updatedAt = _parseDate(map['updatedAt']);
    if (createdAt == null || updatedAt == null) {
      throw BundleCodecException('Device requires createdAt and updatedAt');
    }
    final description = map['description']?.trim();
    final categoryRaw = map['categoryPreset']?.trim() ?? '';
    final locationRaw = map['locationLabel']?.trim() ?? '';
    final parentRaw = map['parentId']?.trim() ?? '';
    final usageUnitRaw = map['usageUnit']?.trim() ?? '';
    final scheduleRaw = map['scheduleType']?.trim() ?? '';
    final intervalRaw = map['intervalValue']?.trim() ?? '';
    final unitRaw = map['intervalUnit']?.trim() ?? '';
    return Device(
      id: id,
      parentId: parentRaw.isEmpty ? null : parentRaw,
      name: name,
      description: (description == null || description.isEmpty)
          ? null
          : description,
      categoryPreset: categoryRaw.isEmpty
          ? null
          : DeviceCategoryPresetX.fromStorage(categoryRaw),
      locationLabel: locationRaw.isEmpty ? null : locationRaw,
      status: DeviceStatusX.fromStorage(map['status'] ?? 'active'),
      usageUnit: usageUnitRaw.isEmpty
          ? null
          : UsageIntervalUnitX.fromStorage(usageUnitRaw),
      currentUsage: int.tryParse(map['currentUsage'] ?? '0') ?? 0,
      scheduleType: scheduleRaw.isEmpty
          ? null
          : ScheduleTypeX.fromStorage(scheduleRaw),
      intervalValue: intervalRaw.isEmpty ? null : int.tryParse(intervalRaw),
      intervalUnit: unitRaw.isEmpty ? null : unitRaw,
      fixedDueAt: _parseDate(map['fixedDueAt']),
      lastMaintainedAt: _parseDate(map['lastMaintainedAt']),
      usageAtLastMaintenance:
          int.tryParse(map['usageAtLastMaintenance'] ?? '0') ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DeviceLog _logFromMap(Map<String, String> map) {
    final id = map['id']?.trim() ?? '';
    final deviceId = map['deviceId']?.trim() ?? '';
    if (id.isEmpty || deviceId.isEmpty) {
      throw BundleCodecException('Log requires id and deviceId');
    }
    final date = _parseDate(map['date']);
    final createdAt = _parseDate(map['createdAt']);
    if (date == null || createdAt == null) {
      throw BundleCodecException('Log requires date and createdAt');
    }
    final notes = map['notes']?.trim();
    final usageRaw =
        map['usageValue']?.trim() ?? map['usageDelta']?.trim() ?? '';
    final unitRaw = map['usageUnit']?.trim() ?? '';
    final kindRaw = map['kind']?.trim() ?? '';
    final costRaw = map['cost']?.trim() ?? '';
    final costCurrencyRaw = map['costCurrency']?.trim() ?? '';
    final vendorRaw = map['vendor']?.trim() ?? '';
    final photoBase64Raw = map['photoBase64']?.trim() ?? '';
    return DeviceLog(
      id: id,
      deviceId: deviceId,
      date: date,
      notes: (notes == null || notes.isEmpty) ? null : notes,
      kind: kindRaw.isEmpty
          ? (usageRaw.isEmpty
                ? DeviceLogKind.maintenanceDone
                : DeviceLogKind.usageUpdate)
          : DeviceLogKindX.fromStorage(kindRaw),
      usageValue: usageRaw.isEmpty ? null : int.tryParse(usageRaw),
      usageUnit: unitRaw.isEmpty
          ? null
          : UsageIntervalUnitX.fromStorage(unitRaw),
      cost: costRaw.isEmpty ? null : double.tryParse(costRaw),
      costCurrency: costCurrencyRaw.isEmpty ? null : costCurrencyRaw,
      vendor: vendorRaw.isEmpty ? null : vendorRaw,
      photoBase64: photoBase64Raw.isEmpty ? null : photoBase64Raw,
      createdAt: createdAt,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static String _csvRow(List<String> cells) => cells.map(_escapeCsv).join(',');

  static String _escapeCsv(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buffer.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          buffer.write(ch);
        }
      } else if (ch == '"') {
        inQuotes = true;
      } else if (ch == ',') {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString());
    return result;
  }

  static Map<String, dynamic> _birthdayToJson(Birthday birthday) => {
    'id': birthday.id,
    'name': birthday.name,
    'birthMonth': birthday.birthMonth,
    'birthDay': birthday.birthDay,
    'calendarSystem': birthday.calendarSystem.storageValue,
    'createdAt': birthday.createdAt.toUtc().toIso8601String(),
    'updatedAt': birthday.updatedAt.toUtc().toIso8601String(),
  };

  static Birthday _birthdayFromJson(Map<String, dynamic> json) =>
      _birthdayFromMap({
        'id': '${json['id']}',
        'name': '${json['name']}',
        'birthMonth': '${json['birthMonth']}',
        'birthDay': '${json['birthDay']}',
        'calendarSystem': json['calendarSystem']?.toString() ?? '',
        'createdAt': '${json['createdAt']}',
        'updatedAt': '${json['updatedAt']}',
      });

  static Birthday _birthdayFromMap(Map<String, String> map) {
    final id = map['id']?.trim() ?? '';
    final name = map['name']?.trim() ?? '';
    if (id.isEmpty || name.isEmpty) {
      throw BundleCodecException('Birthday requires id and name');
    }
    final month = int.tryParse(map['birthMonth']?.trim() ?? '');
    final day = int.tryParse(map['birthDay']?.trim() ?? '');
    if (month == null || day == null) {
      throw BundleCodecException('Birthday requires birthMonth and birthDay');
    }
    final createdAt = _parseDate(map['createdAt']);
    final updatedAt = _parseDate(map['updatedAt']);
    if (createdAt == null || updatedAt == null) {
      throw BundleCodecException('Birthday requires createdAt and updatedAt');
    }
    return Birthday(
      id: id,
      name: name,
      birthMonth: month,
      birthDay: day,
      calendarSystem: CalendarSystem.fromStorage(map['calendarSystem']),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Map<String, dynamic> _placeToJson(Place place) => {
    'id': place.id,
    'name': place.name,
    'kind': place.kind.storageValue,
    'points': place.points
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList(),
    'notes': place.notes,
    'createdAt': place.createdAt.toUtc().toIso8601String(),
    'updatedAt': place.updatedAt.toUtc().toIso8601String(),
  };

  static Place _placeFromJson(Map<String, dynamic> json) {
    final pointsRaw = json['points'];
    final pointsJson = pointsRaw is List
        ? jsonEncode(pointsRaw)
        : (json['pointsJson']?.toString() ?? '[]');
    return _placeFromMap({
      'id': '${json['id']}',
      'name': '${json['name']}',
      'kind': json['kind']?.toString() ?? 'point',
      'pointsJson': pointsJson,
      'notes': json['notes']?.toString() ?? '',
      'createdAt': '${json['createdAt']}',
      'updatedAt': '${json['updatedAt']}',
    });
  }

  static Place _placeFromMap(Map<String, String> map) {
    final id = map['id']?.trim() ?? '';
    final name = map['name']?.trim() ?? '';
    if (id.isEmpty || name.isEmpty) {
      throw BundleCodecException('Place requires id and name');
    }
    final createdAt = _parseDate(map['createdAt']);
    final updatedAt = _parseDate(map['updatedAt']);
    if (createdAt == null || updatedAt == null) {
      throw BundleCodecException('Place requires createdAt and updatedAt');
    }
    final notes = map['notes']?.trim();
    return Place(
      id: id,
      name: name,
      kind: PlaceGeometryKind.fromStorage(map['kind']?.trim() ?? 'point'),
      points: _decodePointsJson(map['pointsJson'] ?? '[]'),
      notes: (notes == null || notes.isEmpty) ? null : notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String _encodePointsJson(List<GeoPoint> points) {
    return jsonEncode([
      for (final point in points)
        {'lat': point.latitude, 'lng': point.longitude},
    ]);
  }

  static List<GeoPoint> _decodePointsJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];
    final decoded = jsonDecode(trimmed);
    if (decoded is! List) return const [];
    return [
      for (final entry in decoded)
        if (entry is Map)
          GeoPoint(
            latitude: (entry['lat'] as num).toDouble(),
            longitude: (entry['lng'] as num).toDouble(),
          ),
    ];
  }
}
