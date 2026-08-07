import 'package:drift/drift.dart';

class SyncOutboxTable extends Table {
  TextColumn get id => text()();

  TextColumn get entityKind => text()();

  TextColumn get operation => text()();

  TextColumn get entityId => text()();

  TextColumn get payloadJson => text()();

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
