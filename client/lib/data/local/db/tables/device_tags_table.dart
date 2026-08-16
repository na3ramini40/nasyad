import 'package:drift/drift.dart';

class DeviceTagsTable extends Table {
  TextColumn get deviceId => text()();

  TextColumn get tagId => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {deviceId, tagId};
}
