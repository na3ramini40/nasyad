import 'package:drift/drift.dart';

class TagsTable extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
