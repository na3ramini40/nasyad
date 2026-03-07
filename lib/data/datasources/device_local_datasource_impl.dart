import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/local/db/dao/device_dao.dart';
import 'package:nasyad/data/models/device_model.dart';

class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final DeviceDao _dao;

  DeviceLocalDataSourceImpl(this._dao);

  @override
  Future<void> deleteDevice(String id) async {
    await _dao.deleteDevice(id);
  }

  @override
  Future<DeviceModel?> getDevice(String id) async {
    final row = await _dao.getDeviceById(id);
    return row == null ? null : DeviceModel.fromTableData(row);
  }

  @override
  Future<List<DeviceModel>> getDevices() async {
    final rows = await _dao.getAllDevices();
    return rows.map(DeviceModel.fromTableData).toList();
  }

  @override
  Future<void> insertDevice(DeviceModel device) async {
    await _dao.insertDevice(device.toTableData());
  }

  @override
  Future<void> updateDevice(DeviceModel device) async {
    await _dao.updateDevice(device.toTableData());
  }
}
