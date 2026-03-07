import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/tables/devices_table.dart';

class DeviceLogsTable extends Table {
  TextColumn get id => text()();

  TextColumn get deviceId => text().references(DevicesTable, #id)();

  DateTimeColumn get date => dateTime()();

  IntColumn get usage => integer().nullable()();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
