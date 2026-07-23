import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';

class ExportDeviceBundle extends Equatable {
  final Device device;
  final List<MaintenanceRule> rules;
  final List<DeviceLog> logs;

  const ExportDeviceBundle({
    required this.device,
    this.rules = const [],
    this.logs = const [],
  });

  @override
  List<Object?> get props => [device, rules, logs];
}

class ExportBundle extends Equatable {
  static const formatName = 'nasyad';
  static const currentVersion = 1;

  final String format;
  final int version;
  final DateTime exportedAt;
  final List<ExportDeviceBundle> devices;

  const ExportBundle({
    this.format = formatName,
    this.version = currentVersion,
    required this.exportedAt,
    required this.devices,
  });

  int get deviceCount => devices.length;

  int get ruleCount => devices.fold(0, (sum, d) => sum + d.rules.length);

  int get logCount => devices.fold(0, (sum, d) => sum + d.logs.length);

  @override
  List<Object?> get props => [format, version, exportedAt, devices];
}

enum ExportScopeKind { all, one, selected }
