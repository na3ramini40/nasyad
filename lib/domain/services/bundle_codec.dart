import 'dart:convert';

import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';
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
    if (version != ExportBundle.currentVersion) {
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
      version: version,
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
        'name',
        'description',
        'status',
        'currentUsage',
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
          device.name,
          device.description ?? '',
          device.status.storageValue,
          '${device.currentUsage}',
          '${device.usageAtLastMaintenance}',
          device.createdAt.toUtc().toIso8601String(),
          device.updatedAt.toUtc().toIso8601String(),
        ]),
      );
    }

    buffer.writeln('#rules');
    buffer.writeln(
      _csvRow([
        'id',
        'deviceId',
        'name',
        'scheduleType',
        'intervalValue',
        'intervalUnit',
        'fixedDueAt',
        'createdAt',
        'updatedAt',
      ]),
    );
    for (final d in bundle.devices) {
      for (final rule in d.rules) {
        buffer.writeln(
          _csvRow([
            rule.id,
            rule.deviceId,
            rule.name,
            rule.scheduleType.storageValue,
            rule.intervalValue?.toString() ?? '',
            rule.intervalUnit ?? '',
            rule.fixedDueAt?.toUtc().toIso8601String() ?? '',
            rule.createdAt.toUtc().toIso8601String(),
            rule.updatedAt.toUtc().toIso8601String(),
          ]),
        );
      }
    }

    buffer.writeln('#logs');
    buffer.writeln(
      _csvRow([
        'id',
        'deviceId',
        'date',
        'notes',
        'usageDelta',
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
            log.usageDelta?.toString() ?? '',
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
    final rulesByDevice = <String, List<MaintenanceRule>>{};
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
          final rule = _ruleFromMap(row);
          rulesByDevice.putIfAbsent(rule.deviceId, () => []).add(rule);
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
      devices: devices.values
          .map(
            (device) => ExportDeviceBundle(
              device: device,
              rules: rulesByDevice[device.id] ?? const [],
              logs: logsByDevice[device.id] ?? const [],
            ),
          )
          .toList(),
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
      buffer.writeln('name: ${device.name}');
      buffer.writeln('description: ${device.description ?? ''}');
      buffer.writeln('status: ${device.status.storageValue}');
      buffer.writeln('currentUsage: ${device.currentUsage}');
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

      for (final rule in d.rules) {
        buffer.writeln('Rule');
        buffer.writeln('id: ${rule.id}');
        buffer.writeln('deviceId: ${rule.deviceId}');
        buffer.writeln('name: ${rule.name}');
        buffer.writeln('scheduleType: ${rule.scheduleType.storageValue}');
        buffer.writeln('intervalValue: ${rule.intervalValue ?? ''}');
        buffer.writeln('intervalUnit: ${rule.intervalUnit ?? ''}');
        buffer.writeln(
          'fixedDueAt: ${rule.fixedDueAt?.toUtc().toIso8601String() ?? ''}',
        );
        buffer.writeln(
          'createdAt: ${rule.createdAt.toUtc().toIso8601String()}',
        );
        buffer.writeln(
          'updatedAt: ${rule.updatedAt.toUtc().toIso8601String()}',
        );
        buffer.writeln();
      }

      for (final log in d.logs) {
        buffer.writeln('Log');
        buffer.writeln('id: ${log.id}');
        buffer.writeln('deviceId: ${log.deviceId}');
        buffer.writeln('date: ${log.date.toUtc().toIso8601String()}');
        buffer.writeln('notes: ${log.notes ?? ''}');
        buffer.writeln('usageDelta: ${log.usageDelta ?? ''}');
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
    final rulesByDevice = <String, List<MaintenanceRule>>{};
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
          final rule = _ruleFromMap(fields);
          rulesByDevice.putIfAbsent(rule.deviceId, () => []).add(rule);
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
      devices: devices.values
          .map(
            (device) => ExportDeviceBundle(
              device: device,
              rules: rulesByDevice[device.id] ?? const [],
              logs: logsByDevice[device.id] ?? const [],
            ),
          )
          .toList(),
    );
  }

  static Map<String, dynamic> _deviceBundleToJson(ExportDeviceBundle d) {
    final device = d.device;
    return {
      'id': device.id,
      'name': device.name,
      'description': device.description,
      'status': device.status.storageValue,
      'currentUsage': device.currentUsage,
      'usageAtLastMaintenance': device.usageAtLastMaintenance,
      'createdAt': device.createdAt.toUtc().toIso8601String(),
      'updatedAt': device.updatedAt.toUtc().toIso8601String(),
      'rules': d.rules.map(_ruleToJson).toList(),
      'logs': d.logs.map(_logToJson).toList(),
    };
  }

  static ExportDeviceBundle _deviceBundleFromJson(Map<String, dynamic> json) {
    final device = _deviceFromMap({
      'id': '${json['id']}',
      'name': '${json['name']}',
      'description': json['description']?.toString() ?? '',
      'status': '${json['status'] ?? 'active'}',
      'currentUsage': '${json['currentUsage'] ?? 0}',
      'usageAtLastMaintenance': '${json['usageAtLastMaintenance'] ?? 0}',
      'createdAt': '${json['createdAt']}',
      'updatedAt': '${json['updatedAt']}',
    });
    final rulesRaw = json['rules'];
    final logsRaw = json['logs'];
    final rules = rulesRaw is List
        ? rulesRaw.map((e) => _ruleFromJson(e as Map<String, dynamic>)).toList()
        : <MaintenanceRule>[];
    final logs = logsRaw is List
        ? logsRaw.map((e) => _logFromJson(e as Map<String, dynamic>)).toList()
        : <DeviceLog>[];
    return ExportDeviceBundle(device: device, rules: rules, logs: logs);
  }

  static Map<String, dynamic> _ruleToJson(MaintenanceRule rule) => {
    'id': rule.id,
    'deviceId': rule.deviceId,
    'name': rule.name,
    'scheduleType': rule.scheduleType.storageValue,
    'intervalValue': rule.intervalValue,
    'intervalUnit': rule.intervalUnit,
    'fixedDueAt': rule.fixedDueAt?.toUtc().toIso8601String(),
    'createdAt': rule.createdAt.toUtc().toIso8601String(),
    'updatedAt': rule.updatedAt.toUtc().toIso8601String(),
  };

  static MaintenanceRule _ruleFromJson(Map<String, dynamic> json) =>
      _ruleFromMap({
        'id': '${json['id']}',
        'deviceId': '${json['deviceId']}',
        'name': '${json['name']}',
        'scheduleType': '${json['scheduleType']}',
        'intervalValue': json['intervalValue']?.toString() ?? '',
        'intervalUnit': json['intervalUnit']?.toString() ?? '',
        'fixedDueAt': json['fixedDueAt']?.toString() ?? '',
        'createdAt': '${json['createdAt']}',
        'updatedAt': '${json['updatedAt']}',
      });

  static Map<String, dynamic> _logToJson(DeviceLog log) => {
    'id': log.id,
    'deviceId': log.deviceId,
    'date': log.date.toUtc().toIso8601String(),
    'notes': log.notes,
    'usageDelta': log.usageDelta,
    'usageUnit': log.usageUnit?.storageValue,
    'createdAt': log.createdAt.toUtc().toIso8601String(),
  };

  static DeviceLog _logFromJson(Map<String, dynamic> json) => _logFromMap({
    'id': '${json['id']}',
    'deviceId': '${json['deviceId']}',
    'date': '${json['date']}',
    'notes': json['notes']?.toString() ?? '',
    'usageDelta': json['usageDelta']?.toString() ?? '',
    'usageUnit': json['usageUnit']?.toString() ?? '',
    'createdAt': '${json['createdAt']}',
  });

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
    return Device(
      id: id,
      name: name,
      description: (description == null || description.isEmpty)
          ? null
          : description,
      status: DeviceStatusX.fromStorage(map['status'] ?? 'active'),
      currentUsage: int.tryParse(map['currentUsage'] ?? '0') ?? 0,
      usageAtLastMaintenance:
          int.tryParse(map['usageAtLastMaintenance'] ?? '0') ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static MaintenanceRule _ruleFromMap(Map<String, String> map) {
    final id = map['id']?.trim() ?? '';
    final deviceId = map['deviceId']?.trim() ?? '';
    final name = map['name']?.trim() ?? '';
    if (id.isEmpty || deviceId.isEmpty || name.isEmpty) {
      throw BundleCodecException('Rule requires id, deviceId, and name');
    }
    final createdAt = _parseDate(map['createdAt']);
    final updatedAt = _parseDate(map['updatedAt']);
    if (createdAt == null || updatedAt == null) {
      throw BundleCodecException('Rule requires createdAt and updatedAt');
    }
    final intervalRaw = map['intervalValue']?.trim() ?? '';
    final unitRaw = map['intervalUnit']?.trim() ?? '';
    return MaintenanceRule(
      id: id,
      deviceId: deviceId,
      name: name,
      scheduleType: ScheduleTypeX.fromStorage(map['scheduleType'] ?? ''),
      intervalValue: intervalRaw.isEmpty ? null : int.tryParse(intervalRaw),
      intervalUnit: unitRaw.isEmpty ? null : unitRaw,
      fixedDueAt: _parseDate(map['fixedDueAt']),
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
    final deltaRaw = map['usageDelta']?.trim() ?? '';
    final unitRaw = map['usageUnit']?.trim() ?? '';
    return DeviceLog(
      id: id,
      deviceId: deviceId,
      date: date,
      notes: (notes == null || notes.isEmpty) ? null : notes,
      usageDelta: deltaRaw.isEmpty ? null : int.tryParse(deltaRaw),
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
