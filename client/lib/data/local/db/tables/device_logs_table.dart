import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/tables/devices_table.dart';

class DeviceLogsTable extends Table {
  TextColumn get id => text()();

  TextColumn get deviceId => text().references(DevicesTable, #id)();

  DateTimeColumn get date => dateTime()();

  TextColumn get notes => text().nullable()();

  TextColumn get kind =>
      text().withDefault(const Constant('maintenanceDone'))();

  IntColumn get usageValue => integer().nullable()();

  TextColumn get usageUnit => text().nullable()();

  RealColumn get cost => real().nullable()();

  TextColumn get costCurrency => text().nullable()();

  TextColumn get vendor => text().nullable()();

  TextColumn get photoPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
