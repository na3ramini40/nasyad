import 'package:drift/drift.dart';

class DevicesTable extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('active'))();

  IntColumn get currentUsage => integer().withDefault(const Constant(0))();

  IntColumn get usageAtLastMaintenance =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
