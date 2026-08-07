import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/device_logs_table.dart';

part 'device_log_dao.g.dart';

@DriftAccessor(tables: [DeviceLogsTable])
class DeviceLogDao extends DatabaseAccessor<AppDatabase>
    with _$DeviceLogDaoMixin {
  DeviceLogDao(super.db);

  Future<List<DeviceLogsTableData>> getLogsForDevice(String deviceId) {
    return (select(deviceLogsTable)
          ..where((t) => t.deviceId.equals(deviceId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Stream<List<DeviceLogsTableData>> watchLogsForDevice(String deviceId) {
    return (select(deviceLogsTable)
          ..where((t) => t.deviceId.equals(deviceId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<DeviceLogsTableData?> getLatestLogForDevice(String deviceId) {
    return (select(deviceLogsTable)
          ..where((t) => t.deviceId.equals(deviceId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<DeviceLogsTableData?> getLogById(String id) {
    return (select(
      deviceLogsTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertLog(DeviceLogsTableCompanion log) {
    return into(deviceLogsTable).insert(log);
  }

  Future<int> upsertLog(DeviceLogsTableCompanion log) {
    return into(deviceLogsTable).insertOnConflictUpdate(log);
  }

  Future<int> deleteLog(String id) {
    return (delete(deviceLogsTable)..where((t) => t.id.equals(id))).go();
  }
}
