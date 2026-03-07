import 'package:nasyad/data/datasources/device_log_local_datasource.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';

class DeviceLogRepositoryImpl extends DeviceLogRepository {
  final DeviceLogLocalDataSource localDataSource;

  DeviceLogRepositoryImpl({required this.localDataSource});

  @override
  Future<void> createLog(DeviceLog log) async {
    final model = DeviceLogModel.fromEntity(log);
    await localDataSource.insertDeviceLog(model);
  }

  @override
  Future<void> deleteLog(String id) async {
    await localDataSource.deleteDeviceLog(id);
  }

  @override
  Future<List<DeviceLog>> getLogsForDevice(String deviceId) async {
    final model = await localDataSource.getLogsForDevice(deviceId);
    return model.map((m) => m.toEntity()).toList();
  }
}
