import 'package:drift/drift.dart';

class PlacesTable extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get kind => text()();

  TextColumn get pointsJson => text()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
