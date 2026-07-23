import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/local/db/dao/device_dao.dart';
import 'package:nasyad/data/models/device_model.dart';

class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final DeviceDao _dao;

  DeviceLocalDataSourceImpl(this._dao);

  @override
  Future<List<DeviceModel>> getActiveDevices() async {
    final rows = await _dao.getActiveDevices();
    return rows.map(DeviceModel.fromTableData).toList();
  }

  @override
  Future<List<DeviceModel>> getAllDevices() async {
    final rows = await _dao.getAllDevices();
    return rows.map(DeviceModel.fromTableData).toList();
  }

  @override
  Future<List<DeviceModel>> getDevicesByIds(List<String> ids) async {
    final rows = await _dao.getDevicesByIds(ids);
    return rows.map(DeviceModel.fromTableData).toList();
  }

  @override
  Stream<List<DeviceModel>> watchActiveDevices() {
    return _dao.watchActiveDevices().map(
      (rows) => rows.map(DeviceModel.fromTableData).toList(),
    );
  }

  @override
  Future<DeviceModel?> getDevice(String id) async {
    final row = await _dao.getDeviceById(id);
    return row == null ? null : DeviceModel.fromTableData(row);
  }

  @override
  Future<void> insertDevice(DeviceModel device) async {
    await _dao.insertDevice(device.toCompanion());
  }

  @override
  Future<void> upsertDevice(DeviceModel device) async {
    await _dao.upsertDevice(device.toCompanion());
  }

  @override
  Future<void> updateDevice(DeviceModel device) async {
    await _dao.replaceDevice(device.toTableData());
  }

  @override
  Future<void> setDeviceStatus(
    String id,
    String status,
    DateTime updatedAt,
  ) async {
    await _dao.setStatus(id, status, updatedAt);
  }
}
