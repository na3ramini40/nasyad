import 'dart:async';
import 'dart:typed_data';

import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class FakeDeviceRepository implements DeviceRepository {
  final List<Device> devices = [];
  final StreamController<List<DeviceSummary>> summariesController =
      StreamController<List<DeviceSummary>>.broadcast();
  final StreamController<DeviceSummary?> detailController =
      StreamController<DeviceSummary?>.broadcast();
  final StreamController<List<Device>> archivedRootsController =
      StreamController<List<Device>>.broadcast();

  List<DeviceSummary> summaries = [];
  ExportBundle? lastImported;
  Object? errorToThrow;

  int createCalls = 0;
  int updateCalls = 0;
  int? lastInitialElapsed;
  final List<(String, DeviceStatus)> statusChanges = [];

  void emitSummaries(List<DeviceSummary> value) {
    summaries = value;
    summariesController.add(value);
  }

  void emitDetail(DeviceSummary? value) {
    detailController.add(value);
  }

  void emitArchivedRoots(List<Device> value) {
    archivedRootsController.add(value);
  }

  List<Device> archivedRootDevices() {
    final byId = {for (final d in devices) d.id: d};
    return devices.where((d) {
      if (d.status != DeviceStatus.archived) return false;
      final parentId = d.parentId;
      if (parentId == null) return true;
      final parent = byId[parentId];
      return parent == null || parent.status != DeviceStatus.archived;
    }).toList();
  }

  void emitError(Object error) {
    summariesController.addError(error);
    detailController.addError(error);
  }

  void _maybeThrow() {
    final error = errorToThrow;
    if (error != null) throw error;
  }

  @override
  Future<List<Device>> getDevices() async {
    _maybeThrow();
    return devices
        .where((d) => d.status == DeviceStatus.active)
        .toList(growable: false);
  }

  @override
  Future<List<Device>> getAllDevices() async {
    _maybeThrow();
    return List.unmodifiable(devices);
  }

  @override
  Future<List<Device>> getDevicesByIds(List<String> ids) async {
    _maybeThrow();
    final idSet = ids.toSet();
    return devices.where((d) => idSet.contains(d.id)).toList(growable: false);
  }

  @override
  Future<List<Device>> getChildren(String parentId) async {
    _maybeThrow();
    return devices
        .where((d) => d.parentId == parentId && d.status == DeviceStatus.active)
        .toList(growable: false);
  }

  @override
  Stream<List<DeviceSummary>> watchRootDeviceSummaries() =>
      summariesController.stream;

  @override
  Stream<List<Device>> watchArchivedRootDevices() =>
      archivedRootsController.stream;

  @override
  Stream<DeviceSummary?> watchDeviceSummary(String deviceId) =>
      detailController.stream;

  @override
  Future<Device?> getDevice(String id) async {
    _maybeThrow();
    for (final device in devices) {
      if (device.id == id) return device;
    }
    return null;
  }

  @override
  Future<void> createDevice(Device device, {int initialElapsed = 0}) async {
    _maybeThrow();
    createCalls++;
    lastInitialElapsed = initialElapsed;
    devices.add(device);
  }

  @override
  Future<void> updateDevice(Device device) async {
    _maybeThrow();
    updateCalls++;
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index >= 0) {
      devices[index] = device;
    } else {
      devices.add(device);
    }
  }

  @override
  Future<void> setDeviceStatus(String id, DeviceStatus status) async {
    _maybeThrow();
    statusChanges.add((id, status));
    final index = devices.indexWhere((d) => d.id == id);
    if (index >= 0) {
      devices[index] = devices[index].copyWith(status: status);
    }
  }

  @override
  Future<void> importBundle(ExportBundle bundle) async {
    _maybeThrow();
    lastImported = bundle;
    for (final item in bundle.devices) {
      final index = devices.indexWhere((d) => d.id == item.device.id);
      if (index >= 0) {
        devices[index] = item.device;
      } else {
        devices.add(item.device);
      }
    }
  }

  @override
  Future<List<Device>> searchActiveDevicesByName(String query) async {
    _maybeThrow();
    final pattern = query.trim().toLowerCase();
    if (pattern.isEmpty) return const [];
    return devices
        .where(
          (device) =>
              device.status == DeviceStatus.active &&
              device.name.toLowerCase().contains(pattern),
        )
        .toList(growable: false);
  }

  Future<void> dispose() async {
    await summariesController.close();
    await detailController.close();
    await archivedRootsController.close();
  }
}

class FakeDeviceLogRepository implements DeviceLogRepository {
  final Map<String, List<DeviceLog>> logsByDevice = {};
  final StreamController<List<DeviceLog>> logsController =
      StreamController<List<DeviceLog>>.broadcast();

  Object? errorToThrow;
  final List<DeviceLog> created = [];
  final List<String> deletedIds = [];

  void _maybeThrow() {
    final error = errorToThrow;
    if (error != null) throw error;
  }

  void emitLogs(List<DeviceLog> logs) => logsController.add(logs);

  void emitError(Object error) => logsController.addError(error);

  @override
  Future<List<DeviceLog>> getLogsForDevice(String deviceId) async {
    _maybeThrow();
    return List.unmodifiable(logsByDevice[deviceId] ?? const []);
  }

  @override
  Stream<List<DeviceLog>> watchLogsForDevice(String deviceId) =>
      logsController.stream;

  @override
  Future<void> createLog(DeviceLog log, {Uint8List? photoBytes}) async {
    _maybeThrow();
    created.add(log);
    logsByDevice.putIfAbsent(log.deviceId, () => []).add(log);
  }

  @override
  Future<void> deleteLog(String id) async {
    _maybeThrow();
    deletedIds.add(id);
    for (final entry in logsByDevice.entries) {
      entry.value.removeWhere((log) => log.id == id);
    }
  }

  Future<void> dispose() => logsController.close();
}

class FakeBirthdayRepository implements BirthdayRepository {
  final List<Birthday> items = [];
  final StreamController<List<Birthday>> controller =
      StreamController<List<Birthday>>.broadcast();

  void emit() => controller.add(List.unmodifiable(items));

  @override
  Stream<List<Birthday>> watchBirthdays() => controller.stream;

  @override
  Future<Birthday?> getBirthday(String id) async {
    return items.where((b) => b.id == id).firstOrNull;
  }

  @override
  Future<void> createBirthday(Birthday birthday) async {
    items.add(birthday);
    emit();
  }

  @override
  Future<void> updateBirthday(Birthday birthday) async {
    final index = items.indexWhere((b) => b.id == birthday.id);
    if (index >= 0) items[index] = birthday;
    emit();
  }

  @override
  Future<void> deleteBirthday(String id) async {
    items.removeWhere((b) => b.id == id);
    emit();
  }

  @override
  Future<List<Birthday>> searchBirthdaysByName(String query) async {
    final pattern = query.trim().toLowerCase();
    if (pattern.isEmpty) return const [];
    return items
        .where((birthday) => birthday.name.toLowerCase().contains(pattern))
        .toList(growable: false);
  }

  Future<void> dispose() => controller.close();
}
