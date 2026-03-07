import 'package:drift/drift.dart';

class DevicesTable extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}