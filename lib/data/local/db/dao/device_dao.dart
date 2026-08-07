import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/devices_table.dart';

part 'device_dao.g.dart';

@DriftAccessor(tables: [DevicesTable])
class DeviceDao extends DatabaseAccessor<AppDatabase> with _$DeviceDaoMixin {
  DeviceDao(super.db);

  Future<List<DevicesTableData>> getActiveDevices() {
    return (select(devicesTable)
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<DevicesTableData>> getActiveRootDevices() {
    return (select(devicesTable)
          ..where((t) => t.status.equals('active') & t.parentId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<DevicesTableData>> getAllDevices() {
    return (select(
      devicesTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<List<DevicesTableData>> getDevicesByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(devicesTable)
          ..where((t) => t.id.isIn(ids))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<DevicesTableData>> getChildren(String parentId) {
    return (select(devicesTable)
          ..where(
            (t) => t.parentId.equals(parentId) & t.status.equals('active'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Stream<List<DevicesTableData>> watchActiveDevices() {
    return (select(devicesTable)
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Stream<List<DevicesTableData>> watchAllDevices() {
    return (select(
      devicesTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<DevicesTableData?> getDeviceById(String id) {
    return (select(
      devicesTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertDevice(DevicesTableCompanion device) {
    return into(devicesTable).insert(device);
  }

  Future<int> upsertDevice(DevicesTableCompanion device) {
    return into(devicesTable).insertOnConflictUpdate(device);
  }

  Future<bool> replaceDevice(DevicesTableData device) {
    return update(devicesTable).replace(device);
  }

  Future<int> setStatus(String id, String status, DateTime updatedAt) {
    return (update(devicesTable)..where((t) => t.id.equals(id))).write(
      DevicesTableCompanion(status: Value(status), updatedAt: Value(updatedAt)),
    );
  }

  Future<void> setStatusForIds(
    List<String> ids,
    String status,
    DateTime updatedAt,
  ) async {
    if (ids.isEmpty) return;
    await (update(devicesTable)..where((t) => t.id.isIn(ids))).write(
      DevicesTableCompanion(status: Value(status), updatedAt: Value(updatedAt)),
    );
  }

  Future<List<DevicesTableData>> searchActiveDevicesByName(String query) {
    final pattern = _likePattern(query);
    return (select(devicesTable)
          ..where((t) => t.status.equals('active') & t.name.like(pattern))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  String _likePattern(String query) {
    final escaped = query
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    return '%$escaped%';
  }
}
