import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/local/db/dao/device_log_dao.dart';
import 'package:nasyad/data/models/device_log_model.dart';

class DeviceLogLocalDataSourceImpl implements DeviceLogLocalDataSource {
  final DeviceLogDao _dao;

  DeviceLogLocalDataSourceImpl(this._dao);

  @override
  Future<List<DeviceLogModel>> getLogsForDevice(String deviceId) async {
    final rows = await _dao.getLogsForDevice(deviceId);
    return rows.map(DeviceLogModel.fromTableData).toList();
  }

  @override
  Stream<List<DeviceLogModel>> watchLogsForDevice(String deviceId) {
    return _dao
        .watchLogsForDevice(deviceId)
        .map((rows) => rows.map(DeviceLogModel.fromTableData).toList());
  }

  @override
  Future<DeviceLogModel?> getLatestLogForDevice(String deviceId) async {
    final row = await _dao.getLatestLogForDevice(deviceId);
    return row == null ? null : DeviceLogModel.fromTableData(row);
  }

  @override
  Future<void> insertDeviceLog(DeviceLogModel log) async {
    await _dao.insertLog(log.toCompanion());
  }

  @override
  Future<void> upsertDeviceLog(DeviceLogModel log) async {
    await _dao.upsertLog(log.toCompanion());
  }

  @override
  Future<void> deleteDeviceLog(String id) async {
    await _dao.deleteLog(id);
  }
}
