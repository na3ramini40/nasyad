import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';

class DeviceSummary extends Equatable {
  final Device device;
  final DeviceLog? latestLog;
  final MaintenanceStatus status;
  final double progress;
  final List<DeviceSummary> children;

  const DeviceSummary({
    required this.device,
    this.latestLog,
    required this.status,
    required this.progress,
    this.children = const [],
  });

  @override
  List<Object?> get props => [device, latestLog, status, progress, children];
}
