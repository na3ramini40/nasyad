import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';

class DeviceSummary extends Equatable {
  final Device device;
  final List<MaintenanceRule> rules;
  final DeviceLog? latestLog;
  final MaintenanceStatus status;
  final double progress;

  const DeviceSummary({
    required this.device,
    required this.rules,
    required this.latestLog,
    required this.status,
    required this.progress,
  });

  @override
  List<Object?> get props => [device, rules, latestLog, status, progress];
}
