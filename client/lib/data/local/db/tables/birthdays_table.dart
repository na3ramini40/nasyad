import 'package:drift/drift.dart';

class BirthdaysTable extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  IntColumn get birthMonth => integer()();

  IntColumn get birthDay => integer()();

  TextColumn get calendarSystem =>
      text().withDefault(const Constant('gregorian'))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
