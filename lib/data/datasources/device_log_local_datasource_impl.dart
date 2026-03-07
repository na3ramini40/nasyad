import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/local/db/dao/device_log_dao.dart';
import 'package:nasyad/data/models/device_log_model.dart';

class DeviceLogLocalDataSourceImpl implements DeviceLogLocalDataSource {
  final DeviceLogDao _dao;

  DeviceLogLocalDataSourceImpl(this._dao);

  @override
  Future<void> deleteDeviceLog(String id) async {
    await _dao.deleteLog(id);
  }

  @override
  Future<List<DeviceLogModel>> getLogsForDevice(String deviceId) async {
    final rows = await _dao.getLogsForDevice(deviceId);
    return rows.map(DeviceLogModel.fromTableData).toList();
  }

  @override
  Future<void> insertDeviceLog(DeviceLogModel log) async {
    await _dao.insertLog(log.toTableData());
  }
}
