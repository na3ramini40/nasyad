import 'package:drift/drift.dart';

class DevicesTable extends Table {
  TextColumn get id => text()();

  TextColumn get parentId => text().nullable()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('active'))();

  TextColumn get usageUnit => text().nullable()();

  IntColumn get currentUsage => integer().withDefault(const Constant(0))();

  TextColumn get scheduleType => text().nullable()();

  IntColumn get intervalValue => integer().nullable()();

  TextColumn get intervalUnit => text().nullable()();

  DateTimeColumn get fixedDueAt => dateTime().nullable()();

  DateTimeColumn get lastMaintainedAt => dateTime().nullable()();

  IntColumn get usageAtLastMaintenance =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
