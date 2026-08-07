import 'dart:convert';

import 'package:nasyad/data/services/log_photo_storage.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';
import 'package:nasyad/domain/services/transfer/transfer_data_handler.dart';

class DeviceTransferHandler implements TransferDataHandler {
  DeviceTransferHandler(this._devices, this._logs, this._photos);

  final DeviceRepository _devices;
  final DeviceLogRepository _logs;
  final LogPhotoStorage _photos;

  @override
  String get key => TransferSectionKey.devices;

  @override
  Future<void> collectInto(
    ExportBundleDraft draft, {
    required ExportScopeKind scope,
    required List<String> deviceIds,
  }) async {
    final devices = switch (scope) {
      ExportScopeKind.all => await _devices.getAllDevices(),
      ExportScopeKind.one ||
      ExportScopeKind.selected => await _devices.getDevicesByIds(deviceIds),
    };

    final bundles = <ExportDeviceBundle>[];
    for (final device in devices) {
      final logs = await _logs.getLogsForDevice(device.id);
      final enriched = await Future.wait(logs.map(_enrichLogForExport));
      bundles.add(ExportDeviceBundle(device: device, logs: enriched));
    }
    draft.devices = bundles;
  }

  @override
  bool hasDataIn(ExportBundle bundle) => bundle.devices.isNotEmpty;

  @override
  Future<void> applyFrom(ExportBundle bundle) {
    return _devices.importBundle(
      ExportBundle(exportedAt: bundle.exportedAt, devices: bundle.devices),
    );
  }

  Future<DeviceLog> _enrichLogForExport(DeviceLog log) async {
    if (log.photoPath == null) return log;
    final bytes = await _photos.readBytes(log.photoPath);
    if (bytes == null) return log;
    return log.copyWith(photoBase64: base64Encode(bytes));
  }
}
