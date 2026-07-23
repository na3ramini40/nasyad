import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/tables/devices_table.dart';

class MaintenanceRulesTable extends Table {
  TextColumn get id => text()();

  TextColumn get deviceId => text().references(DevicesTable, #id)();

  TextColumn get name => text()();

  TextColumn get scheduleType => text()();

  IntColumn get intervalValue => integer().nullable()();

  TextColumn get intervalUnit => text().nullable()();

  DateTimeColumn get fixedDueAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
