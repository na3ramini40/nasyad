import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/devices_table.dart';

part 'device_dao.g.dart';

@DriftAccessor(tables: [DevicesTable])
class DeviceDao extends DatabaseAccessor<AppDatabase> with _$DeviceDaoMixin {
  DeviceDao(AppDatabase db) : super(db);

  Future<List<DevicesTableData>> getAllDevices() {
    return select(devicesTable).get();
  }

  Future<DevicesTableData?> getDeviceById(String id) {
    return (select(
      devicesTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertDevice(DevicesTableData device) {
    return into(devicesTable).insert(device);
  }

  Future<bool> updateDevice(DevicesTableData device) {
    return update(devicesTable).replace(device);
  }

  Future<int> deleteDevice(String id) {
    return (delete(devicesTable)..where((table) => table.id.equals(id))).go();
  }
}
