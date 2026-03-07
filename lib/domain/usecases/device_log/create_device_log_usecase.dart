import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';

class CreateDeviceLogUsecase{
  final DeviceLogRepository repository;
  CreateDeviceLogUsecase(this.repository);
  
  Future<void> call(DeviceLog log){
    return repository.createLog(log);
  }
}