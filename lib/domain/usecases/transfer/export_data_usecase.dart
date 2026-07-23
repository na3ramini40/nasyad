import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';

class ExportDataResult {
  const ExportDataResult({
    required this.bundle,
    required this.content,
    required this.format,
    required this.fileName,
  });

  final ExportBundle bundle;
  final String content;
  final ExportFormat format;
  final String fileName;
}

class ExportDataUsecase {
  ExportDataUsecase(this._devices, this._logs);

  final DeviceRepository _devices;
  final DeviceLogRepository _logs;

  Future<ExportDataResult> call({
    required ExportScopeKind scope,
    required ExportFormat format,
    List<String> deviceIds = const [],
  }) async {
    final devices = switch (scope) {
      ExportScopeKind.all => await _devices.getAllDevices(),
      ExportScopeKind.one || ExportScopeKind.selected =>
        await _devices.getDevicesByIds(deviceIds),
    };

    if (scope == ExportScopeKind.one && deviceIds.length != 1) {
      throw ArgumentError('One-device export requires exactly one device id');
    }
    if (scope == ExportScopeKind.selected && deviceIds.isEmpty) {
      throw ArgumentError('Selected export requires at least one device id');
    }
    if (devices.isEmpty) {
      throw StateError('No devices to export');
    }

    final bundles = <ExportDeviceBundle>[];
    for (final device in devices) {
      final rules = await _devices.getRulesForDevice(device.id);
      final logs = await _logs.getLogsForDevice(device.id);
      bundles.add(
        ExportDeviceBundle(device: device, rules: rules, logs: logs),
      );
    }

    final bundle = ExportBundle(
      exportedAt: DateTime.now().toUtc(),
      devices: bundles,
    );
    final content = BundleCodec.encode(bundle, format);
    final stamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final fileName = 'nasyad-export-$stamp.${format.fileExtension}';

    return ExportDataResult(
      bundle: bundle,
      content: content,
      format: format,
      fileName: fileName,
    );
  }
}
