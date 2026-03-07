import 'package:nasyad/data/datasources/device_local_datasource.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl extends DeviceRepository {
  final DeviceLocalDataSource localDataSource;

  DeviceRepositoryImpl({required this.localDataSource});

  @override
  Future<void> createDevice(Device device) async {
    final model = DeviceModel.fromEntity(device);
    await localDataSource.insertDevice(model);
  }

  @override
  Future<void> deleteDevice(String id) async {
    await localDataSource.deleteDevice(id);
  }

  @override
  Future<Device?> getDevice(String id) async {
    final model = await localDataSource.getDevice(id);
    return model?.toEntity();
  }

  @override
  Future<List<Device>> getDevices() async {
    final model = await localDataSource.getDevices();
    return model.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updateDevice(Device device) async {
    final model = DeviceModel.fromEntity(device);
    await localDataSource.updateDevice(model);
  }
}
