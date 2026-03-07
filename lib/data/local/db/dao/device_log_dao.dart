import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/device_logs_table.dart';

part 'device_log_dao.g.dart';

@DriftAccessor(tables: [DeviceLogsTable])
class DeviceLogDao extends DatabaseAccessor<AppDatabase>
    with _$DeviceLogDaoMixin {
  DeviceLogDao(AppDatabase db) : super(db);

  Future<List<DeviceLogsTableData>> getLogsForDevice(String deviceId) {
    return (select(deviceLogsTable)
      ..where((table) => table.deviceId.equals(deviceId))
      ..orderBy([(table) => OrderingTerm.desc(table.date)]))
        .get();
  }

  Future<int> insertLog(DeviceLogsTableData log) {
    return into(deviceLogsTable).insert(log);
  }

  Future<int> deleteLog(String id) {
    return (delete(deviceLogsTable)..where((table) => table.id.equals(id))).go();
  }

  Future<int> deleteLogsByDevice(String deviceId) {
    return (delete(
      deviceLogsTable,
    )..where((table) => table.deviceId.equals(deviceId))).go();
  }
}
