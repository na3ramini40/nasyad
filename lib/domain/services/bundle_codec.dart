import 'dart:convert';

import 'package:nasyad/domain/entities/device.dart';
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
    if (trimmed.startsWith('#devices') || trimmed.startsWith('# devices')) {
      return ExportFormat.csv;
    }
    if (trimmed.startsWith('Nasyad export') || trimmed.startsWith('Device')) {
      return ExportFormat.plainText;
    }
    if (trimmed.contains('#devices') || trimmed.contains('#rules')) {
      return ExportFormat.csv;
    }
    throw BundleCodecException('Unable to detect export format');
  }

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
    if (version != 1 && version != ExportBundle.currentVersion) {
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
    return ExportBundle(
      format: format,
      version: ExportBundle.currentVersion,
      exportedAt: exportedAt,
      devices: devices,
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
            log.createdAt.toUtc().toIso8601String(),
          ]),
        );
      }
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
        default:
          throw BundleCodecException('Unknown CSV section: $section');
      }
    }

    if (devices.isEmpty) {
      throw BundleCodecException('CSV contains no devices');
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
      buffer.writeln('status: ${device.status.storageValue}');
      buffer.writeln('usageUnit: ${device.usageUnit?.storageValue ?? ''}');
      buffer.writeln('currentUsage: ${device.currentUsage}');
      buffer.writeln('scheduleType: ${device.scheduleType?.storageValue ?? ''}');
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
        buffer.writeln('createdAt: ${log.createdAt.toUtc().toIso8601String()}');
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  static ExportBundle decodePlainText(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    final devices = <String, Device>{};
    final scheduleByDevice = <String, Map<String, String>>{};
    final logsByDevice = <String, List<DeviceLog>>{};

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
      if (trimmed == 'Device' || trimmed == 'Rule' || trimmed == 'Log') {
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

    if (devices.isEmpty) {
      throw BundleCodecException('Plain text contains no devices');
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
    );
  }

  static Map<String, dynamic> _deviceBundleToJson(ExportDeviceBundle d) {
    final device = d.device;
    return {
      'id': device.id,
      'parentId': device.parentId,
      'name': device.name,
      'description': device.description,
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
    'createdAt': '${json['createdAt']}',
  });

  static Device _mergeLegacyRule(Device device, Map<String, String>? rule) {
    if (rule == null || device.hasSchedule) return device;
    final typeRaw = rule['scheduleType']?.trim() ?? '';
    if (typeRaw.isEmpty) return device;
    final intervalRaw = rule['intervalValue']?.trim() ?? '';
    final unitRaw = rule['intervalUnit']?.trim() ?? '';
    final scheduleType = ScheduleTypeX.fromStorage(typeRaw);
    final usageUnit = unitRaw.isNotEmpty &&
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
}
