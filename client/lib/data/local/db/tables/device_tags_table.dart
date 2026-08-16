import 'package:drift/drift.dart';

class DeviceTagsTable extends Table {
  TextColumn get deviceId => text()();

  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {deviceId, tagId};
}
